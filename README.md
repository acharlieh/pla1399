# .conf23 PLA1399 *A Little Help With Splunk Configuration*

This repository will contain materials used with the Interactive Workshop [PLA1399 *A Little Help With Splunk Configuration*](https://conf.splunk.com/session-catalog.html?search=PLA1399) which will be given at .conf23, July 17-23 in Las Vegas.

During this workshop, Docker will be utilized to enable the execution of a basic, two-tier architecture, showcasing specific interactions between an indexer and a search head.

The contents of this repository will be further updated with needed materials as the session approaches, but having the below pre-work completed in advance would help ensure that you are adequately prepared:

## Initial Setup

1. Download and install [Docker Desktop](https://www.docker.com/)
    1. You'll likely need to register a [Docker Hub](https://hub.docker.com/) account if you do not have one already
    2. If you're using MacOS 12.5 or above, you'll need to enable the Virtualization Framework (Settings > General)
       * On Apple Silicon you'll also want to enable Rosetta (Settings > Features in Development > Beta features)
2. Pre-fetch the container images that we're going to use
    * `docker pull --platform linux/amd64 splunk/splunk:9.0.4.1` (606.4 MB)
    * `docker pull busybox:latest` (~2 MB)

## Useful Links
* Consider joining [the Splunk Community](https://docs.splunk.com/Documentation/Community/)
* The latest version of [*"Admin's Little Helper for Splunk"*](https://splunkbase.splunk.com/app/6368) can be found on Splunkbase
