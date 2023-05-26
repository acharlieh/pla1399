# 1 - Global Context

We have a configured HEC token. But what is the value of the token we need to use to send data?

## What to know in this scenario

* Global Context is most how configuration is resolved without a Splunk user or application in context. Examples being:
    * inputs.conf
    * indexes.conf
    * limits.conf
    * (Input / Parsing time) props.conf & transforms.conf
* [Precedence of what wins](https://docs.splunk.com/Documentation/Splunk/latest/Admin/Wheretofindtheconfigurationfiles#Precedence_within_global_context): 
    * ONLY ON INDEXER CLUSTERS: peer-apps (formerly: slave-apps) / (appname) / local in forward lexographical order 0-9A-Za-z by appname.
    * system / local
    * apps / (appname) / local in forward lexographical order 0-9A-Za-z by appname.
    * ONLY ON INDEXER CLUSTERS: peer-apps (formerly: slave-apps) / (appname) / default in forward lexographical order 0-9A-Za-z by appname. 
    * apps / (appname) / default in forward lexographical order 0-9A-Za-z by appname.
    * system / default
    * code defined defaults if available/applicable
* the `/services` context for REST APIs "typically" means global scope. (Sometimes it means the current user / default app scope...)

## Steps!

1. Start by getting a shell as the splunk user in the $SPLUNK_ETC directory on the indexer
    1. `docker exec -u splunk -it pla-1399-indexer-1 /bin/bash`
    2. `source /opt/splunk/bin/setSplunkEnv`
    3. `cd $SPLUNK_ETC`
    * PRO TIP: sourcing setSplunkEnv sets SPLUNK_ environment variables, puts `splunk` on your path AND enables tab completion of splunk commands if supported for your shell. 
2. Let's use Linux utilities to find all places that we've defined a HEC token
    1. `find . -name inputs.conf -exec grep http: {} +`
    2. Look at the token value in each file
    * <details><summary>Answers</summary>

        * You should have found two locations
        ```
        ./apps/bcf_idx_configs/local/inputs.conf:[http://splunk_hec_token]
        ./apps/splunk_httpinput/local/inputs.conf:[http://splunk_hec_token]
        ```
        * And found that the tokens are different. Here's one method:
        ```
        [splunk@idx-18557758657 etc]$ grep -B2 ^token ./apps/{splunk_httpinput,bcf_idx_configs}/local/inputs.conf
        ./apps/splunk_httpinput/local/inputs.conf-[http://splunk_hec_token]
        ./apps/splunk_httpinput/local/inputs.conf-disabled = 0
        ./apps/splunk_httpinput/local/inputs.conf:token = 73657420-6279-2064-2E63-6F6D706F7365
        --
        ./apps/bcf_idx_configs/local/inputs.conf-
        ./apps/bcf_idx_configs/local/inputs.conf-[http://splunk_hec_token]
        ./apps/bcf_idx_configs/local/inputs.conf:token = F9202A13-304E-4A97-A285-5C07D4C73D18
        ```
      </details>

3. Which one wins?
    1. CLI on HEC server, use btool - `splunk cmd btool inputs list http: --debug`
        * <details><summary>Output</summary>

            ```
            /opt/splunk/etc/apps/bcf_idx_configs/local/inputs.conf  [http://splunk_hec_token]
            /opt/splunk/etc/system/default/inputs.conf              _rcvbuf = 1572864
            /opt/splunk/etc/apps/bcf_idx_configs/local/inputs.conf  allowQueryStringAuth = true
            /opt/splunk/etc/apps/splunk_httpinput/local/inputs.conf disabled = 0
            /opt/splunk/etc/system/default/inputs.conf              host = $decideOnStartup
            /opt/splunk/etc/system/default/inputs.conf              index = default
            /opt/splunk/etc/apps/bcf_idx_configs/local/inputs.conf  sourcetype = pla1399_webhook
            /opt/splunk/etc/apps/bcf_idx_configs/local/inputs.conf  token = F9202A13-304E-4A97-A285-5C07D4C73D18
            ```
          </details>

    2. Web UI (Cloud, or on same node as HEC (not here)): Settings > Data Inputs > HTTP Event Collector
    3. Search (Enterprise on a node that distributes to HEC, not cloud)
        * properties rest endpoint for getting the global resolved value for a conf key:
        `| rest /services/properties/inputs/http%3A%2F%2Fsplunk_hec_token/token splunk_server=idx-*`
        * wrapper endpoint specific for the type of object: /data/inputs/http is the endpoint for HEC token configuration
        ` | rest /services/data/inputs/http f=token`
            * This is not necessarily reliable: ` | rest /services/data/inputs/http/splunk_hec_token f=token splunk_server=idx-* f=token` gives the wrong answer!
            *  `| rest /servicesNS/nobody/-/data/inputs/http/splunk_hec_token f=token splunk_server=idx-* f=token` can be used to see both potential answers
        * conf endpoints to see files in place: `| rest /servicesNS/nobody/-/configs/conf-inputs/http%3A%2F%2Fsplunk_hec_token f=token splunk_server=idx-*`
