# 2 - App / User Context

We have a search job that is sending results to a webhook. 
(Our webhook happens to be the HEC endpoint & token found with the [previous section](./01_Global.md)).
We set the correct hostname in `bcf_sh_configs` but the instance specific splunkweb host and port is being sent instead. Why?

Additionally, our data coming in via HEC, we have a search time field called `team` that should be taking the value `"bcf_splunk_monitoring"` but instead is `"unspecified"` from the TA. 

## What to know in this scenario

* App / User Context is how configuration is resolved with a Splunk user/app in context. (Most often Search Time things). Examples:
    * savedsearches.conf
    * alert_actions.conf
    * commands.conf
    * (Search time) props.conf & transforms.conf
* [Precedence of what wins](https://docs.splunk.com/Documentation/Splunk/latest/Admin/Wheretofindtheconfigurationfiles#Precedence_within_global_context).  (for each of these individual locations, local wins over default for each location... but then these locations are merged together)
    1. users / (current username) / (appname)
    2. apps / (current app name)
    3. apps / (appname) - for all other apps, for exported settings only, in REVERSE lexographic order (z-aZ-A9-0)
    4. system 
    5. (code level defaults if applicable)
* The `/servicesNS/username/appname` context for REST APIs "typically" is user app context. (Sometimes it means the specific location, as opposed to resolve what is visible for this location)
    * the appname `system` of course refers to system (e.g. /system as opposed to /apps/system )
    * the username `nobody` refers to context without a user (e.g. underneath /apps/appname as opposed to /users/username/appname)
    * either username or appname can take a token of `-` meaning `all usernames / appnames`

## Identifying & Fixing the Alert Action Hostname Steps

1. Confirm the issue exists, get the user/app context for the search
    1. Log into the search head UI and get information from the most recent result
        * Open a search view and run:
        ```
        index=main sourcetype=pla1399_webhook | head 1
        ```
        * We see the issue exists because the hostname/port is wrong `http://sh-i-f09fa7b868756773.buttercupfoods.corp:8000` as opposed to `https://splunk.buttercupfoods.com:443` as is in app_sources/bcf_sh_configs/local/alert_actions.conf
        * But this URL should give you Search ID (`sid=`) (and an idea of the app name you're looking for
    2. With the search id, let's use the `_audit` index to get the user and confirm the app.
        * Here's a template:
        ```
        index=_audit TERM(action=search) search_id="'sid'" | stats values(info) values(user) values(app) by search_id
        ```
        * The search_id in `_audit` logs shows up in single quote marks, so if the search id you got previously was `scheduler__foo_bar_baz` your search would be:
        ```
        index=_audit TERM(action=search) search_id="'scheduler__foo_bar_baz'" | stats values(info) values(user) values(app) by search_id
        ```
        * <details><summary>Answers</summary>

          You should have gotten `splunk-system-user` for user and `bcf_secops` for app
          </details>

2. Let's use btool to see what hostname value is winning for the webhook
    1. Let's get a shell as the splunk user on the search head
        1. `docker exec -u splunk -it pla-1399-search-1 /bin/bash`
        2. `source /opt/splunk/bin/setSplunkEnv`
    2. Alert actions are being used with a Search... so is used by Splunk in a user/app context.Executing btool we need to provide the user and app context:
        * `splunk cmd btool alert_actions list webhook --debug --app=bcf_secops --user=splunk-system-user`
        * <details><summary>Output</summary>
            ```
            /opt/splunk/etc/apps/alert_webhook/default/alert_actions.conf [webhook]
            /opt/splunk/etc/system/default/alert_actions.conf             command = sendalert $action_name$ results_file="$results.file$" results_link="$results.url$"
            /opt/splunk/etc/apps/alert_webhook/default/alert_actions.conf description = Generic HTTP POST to a specified URL
            /opt/splunk/etc/system/default/alert_actions.conf             enable_allowlist = false
            /opt/splunk/etc/system/default/alert_actions.conf             forceCsvResults = auto
            /opt/splunk/etc/system/default/alert_actions.conf             hostname = 
            /opt/splunk/etc/apps/alert_webhook/default/alert_actions.conf icon_path = webhook.png
            /opt/splunk/etc/apps/alert_webhook/default/alert_actions.conf is_custom = 1
            /opt/splunk/etc/apps/alert_webhook/default/alert_actions.conf label = Webhook
            /opt/splunk/etc/system/default/alert_actions.conf             maxresults = 10000
            /opt/splunk/etc/system/default/alert_actions.conf             maxtime = 5m
            /opt/splunk/etc/apps/alert_webhook/default/alert_actions.conf param.user_agent = Splunk/$server.guid$
            /opt/splunk/etc/apps/alert_webhook/default/alert_actions.conf payload_format = json
            /opt/splunk/etc/apps/alert_webhook/default/alert_actions.conf python.version = python3
            /opt/splunk/etc/system/default/alert_actions.conf             track_alert = 0
            /opt/splunk/etc/system/default/alert_actions.conf             ttl = 10p
            ```

          </details>

        * Notice that `hostname =` is set as blank from system/default... but also when we use btool in a global context (omitting the `--app` and `--user` parameters) the hostname comes set from the `bcf_sh_configs` app as expected. As system is the lowest priority for app/user context AND the hostname is coming from an app in a global context, the issue is that we forgot to export configurations from that app!
3. Fixing the problem (graphically so we don't need to do restarts)
    1. From the Search Head UI, get to the app management screen
        * If you're on the launcher app, click the big gear in the upper left list of apps
        * If you're inside any other app, click the `Apps` menu and then `Manage Apps`
    2. Find the `bcf_sh_configs` app and click `Permissions`
    3. Click the radial button next to "All Apps" and click Save (The app should show as "Global" in the UI
    4. (for speeding up the workshop) Let's adjust the speed at which we dispatch the searches:
        * Goto the Security Operations app, and the Reports View
        * Next to DataCollection, click Edit > Edit Schedule
        * Remove the `/5` from the cron expression leaving `* * * * *`
        * Click Save (this means we should only have to wait a minute instead of 5 to see results.
4. Rerun the search from step 1 and see that after the next run, the hostname changed

## Identifying & Fixing the Calculated Field

1. Remember - Search time, therefore user/app parameters.
2. Exercise for the user for now :)
