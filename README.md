# .conf23 PLA1399 *A Little Help With Splunk Configuration*

This repository contains materials used with the Interactive Workshop [PLA1399 *A Little Help With Splunk Configuration*](https://conf.splunk.com/session-catalog.html?search=PLA1399) as given at .conf23, July 17-23 in Las Vegas.

During this workshop, Docker will be utilized to enable the execution of a basic, two-tier architecture, showcasing specific interactions between an indexer and a search head.

## Initial Setup

1. Download and install [Docker Desktop](https://www.docker.com/)
    1. You'll likely need to register a [Docker Hub](https://hub.docker.com/) account if you do not have one already
    2. If you're using MacOS 12.5 or above, you'll need to enable Docker to use the Virtualization Framework (Docker Settings > General)
       * On Apple Silicon you'll also want Docker to use Rosetta (Docker Settings > Features in Development > Beta features)
2. Before class, pre-fetch the container images that we're going to use. (If not pre-done, this will happen with step 4, and will make that take longer)
    * `docker pull --platform linux/amd64 splunk/splunk:9.0.4.1` (606.4 MB)
    * `docker pull busybox:latest` (~2 MB)
3. Clone / Export the latest version of this repository to a location that Docker is allowed to bind mount
    * Your user's home directory usually is in this list by default
    * Check Docker Desktop > Settings > Resources > File Sharing to see/modify this list
4. From the root of this repository, start the containers: `docker compose up -d`

## Useful Links
* Consider joining [the Splunk Community](https://docs.splunk.com/Documentation/Community/)
    * In particular if you're on Splunk Usergroups Slack, and have questions before the workshop, join us in the [#buttercupfoods](https://splunk-usergroups.slack.com/archives/C05GG33S937) channel.
    * If you're not on Splunk Usergroups Slack, request an invite at [https://splk.it/slack](https://splk.it/slack).
* The latest version of [*"Admin's Little Helper for Splunk"*](https://splunkbase.splunk.com/app/6368) can be found on Splunkbase

## Environment Notes, Docker Tips, and Scenario Steps
* [Docker Tips and Envrionment Reference](./docs/00_Environment.md)
1. First Scenario - [Global Context](./docs/01_Global.md)
2. Second Scenario - [App/User Context](./docs/02_AppUser.md)
3. Third Scenario - [The Knowledge Bundle](./docs/03_Knowledge.md)
4. Fourth - [A Little Helper](./docs/04_LittleHelp.md)

# Copyright & License
* Copyright 2023 Splunk, Inc.
* See the [Splunk General Terms](https://www.splunk.com/en_us/legal/splunk-general-terms.html) for more info
