# 4 - A Little Help

Hi it's me... author of [*"Admin's Little Helper for Splunk"*](https://splunkbase.splunk.com/app/6368) which is published on Splunkbase

It currently has two search commands to help make your lives easier, instead of jumping to command lines so often. (Which is super important for those of you who are Splunk Cloud admins)

Each of the scenarios we did today can be done with admin's little helper

Open your search head UI and get to a search view

## Exercises we've been over

### Global Config

The token value for all HEC tokens on peers searchable from this search head
```
| btool inputs list http: --debug --kvpairs
| search token=*
| table splunk_server btool.stanza token
```

### AppUser Config

Webhook alert_actions configuration for the same app user as running the search:

```
| btool alert_actions list webhook --app --user
```


Calculated fields for the workshop sourcetypes on the search head and as replicated to the indexer: 

```
| btool props list pla1399 --app --user --kvpairs | search btool.keys=EVAL-*
```


### Knowledge Bundle

Largest files that are estimated to be in the next knowledge bundle.

```
| bundlefiles bundle=computed | sort - bytes
```

Most recently edited files greater than 0.5 MB 

```
| bundlefiles bundle=computed | where bytes>pow(2,20)/2 | sort - _time
```

## Other things to try!
