# 3 - The Knowledge Bundle

## Bad Analyst, No Cookie

Uh oh, someone stole the Buttercup Foods Cookies from the Cookie Jar! Let's have our SOC  analyst start working on this:

1. Let's get a shell as the splunk user on the search head
    1. `docker exec -u splunk -it pla-1399-search-1 /bin/bash`
    2. `source /opt/splunk/bin/setSplunkEnv`
2. We're going to simulate the analyst doing their work with the following:
    * `splunk _internal call /servicesNS/nobody/bcf_secops/saved/searches/DoInvestigation/dispatch -post:trigger_actions 1 -auth admin:password`
    * You should see a Search ID be dispatched
3. Now we can take off our analyst hat, and move on with our regularly scheduled program

## What to know in this scenario

For installations of any significant size, you're going to have a separation of Search Heads and Indexers. Search time field extractions, automatic lookups, calculated fields, custom search commands, all can happen on the indexers, so the indexers need to have the config & code from the search head in order to do the right/consistent thing.

This is accomplished with knowledge bundle replication. The Search Head (Or Search Head Cluster captain) regularily gathers up the knowledge objects, tars them up and distributes them to the indexers.

But something seems to have gone a bit sideways on us here.

## Who Set Us Up the Bomb?

1. In the UI of the search head, about a minute after the analyst did it's work you should see a new message has appeared. Namely:
    > Knowledge bundle size=###MB exceeds max limit=100MB. Distributed searches are running against an outdated knowledge bundle
2. Ok but which file(s) are causing the problem? Let's go back to our search head shell and try to find out:
    1. Same commands as above to get the shell, but then `cd $SPLUNK_ETC`
    2. `find . -type f -newer instance.cfg -size +5192k -exec ls -halt {} +`
    3. You should see two lookup files that are greater than 5 MB
3. If it's been 10 minutes since the analyst has run things... we should be able to see events in `_audit` new files that were modified recently:
    ```
    index="_audit" host=sh-* (TERM(action=add) OR TERM(action=update)) path=* size>4078185
    | convert timeformat="%c" mktime(modtime)
    | where modtime>relative_time(now(),"-d@d") 
    ```
4. But are these the problem? Or was it a number of smaller files builidng up to be no longer managable? 🤷

## What can we do to help solve the problem?

1. We can temporarily bump the maximum allowed size of the bundle
    * Note: *temporarily* larger bundles mean longer replication times, especially with more indexers. (cascading replication mode is a bit outside of scope here)
    1. Get a shell as the Splunk User on the search head
    2. Install the 000_workaround_kbsize_sh app: `splunk install app /apps/built_000_workaround_kbsize_sh.tgz -auth admin:password`
    3. Restart Splunk `splunk restart`
2. Logging into the search head UI, we'll see that we now have a different problem, and cannot run searches! OOPS! Increasing bundle size means correspondingly increasing max_content_length on the indexers. 
    1. Get a shell as the Splunk User on the **Indexer**
    2. Install the 000_workaround_kbsize_idx app: `splunk install app /apps/built_000_workaround_kbsize_idx.tgz -auth admin:password`
    3. Restart splunk
3. With the bundle rebuilding we can look at the bundle itself and see what's in there:
    1. Get a shell as the Splunk User on the search head
    2. `cd $SPLUNK_HOME/var/run`
    3. Find the 10 largest files in the latest bundle: `tar tvf $(find . -name '*.bundle' | sort -r | head -n1) | sort -k3 -n -r | head -n10`
4. We're pretty sure the lookups from the investigation are the problem so let's deny list them:
    * Install the 000_kb_noinvestigation app on the search head & restart
        * `splunk install app /apps/built_000_kb_noinvestigation.tgz -auth admin:password`
    * See the lookups no longer be present in the latest bundle as above
5. We can take this one step further, and default deny all lookups larger than a certain size. This is in the 000_kb_excludelookupsize app, and left to the reader.
