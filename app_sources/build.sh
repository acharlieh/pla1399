#!/bin/sh
set -e
find /apps -type f -name 'built_*.tgz' -delete
find /apps /source -type f -name '.DS_Store' -delete

cd /source
for d in */ ; do
	app="${d%/}"
	tar czvf "/apps/built_${app}.tgz" "${app}"
done
