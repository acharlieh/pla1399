# 0 - Environmental Crash Course & Docker References
 
This repository's docker compose file contains definitions for specific instances for the "Buttercup Foods" splunk environment. This is a minimal environment, to be able to show certain interactions, without needing too many resources

When starting the environment, you'll notice a `pla-1399-build-1` container start first and terminate. This container took the apps under app_sources, and made tarballs starting with built_* under the app_packages folder. These apps are then installed on the `pla-1399-search-1` and `pla-1399-indexer-1` containers as appropriate.

## Some References
* Start all containers in the background (as a daemon) `docker compose up -d`
* Fast kill and remove containers `docker compose kill; docker compose down`
  * Clean up no longer used resources from docker: `docker system prune -f; docker volume prune -f`
* See the running containers and mapped ports: `docker ps`
  * A port definiton like `127.0.0.1:12345->8000/tcp` means that the Splunk Web port (`8000`) from the container is available on your machine at localhost port `12345`

## How do I get a bash shell as the Splunk User? 

### Docker Desktop

Click on the container you want a shell, and click the "Terminal" tab. Then:
1. `sudo su - splunk`
2. `source /opt/splunk/bin/setSplunkEnv`

### Your Terminal (Search Head)

1. `docker exec -u splunk -it pla-1399-search-1 /bin/bash`
2. `source /opt/splunk/bin/setSplunkEnv`

### Your Terminal (Indexer)

1. `docker exec -u splunk -it pla-1399-indexer-1 /bin/bash`
2. `source /opt/splunk/bin/setSplunkEnv`
