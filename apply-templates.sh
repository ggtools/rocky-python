#!/usr/bin/env bash

VERSIONS_URL=${VERSIONS_URL:-https://raw.githubusercontent.com/docker-library/python/master/versions.json}

VERSIONS_JSON=$(mktemp -t versions.XXXXXXXX.json)

curl -s -L -o $VERSIONS_JSON $VERSIONS_URL

for version in $(jq -r 'keys[]' $VERSIONS_JSON)
do
    if [ -d $version ]
    then
        echo "Generating templates for $version"
        PY_BRANCH="$version" gomplate -d versions=$VERSIONS_JSON -t ./templates/support.t --input-dir=templates --output-dir=$version
    else
        echo "Skipping version $version"
    fi
done

rm -f $VERSIONS_JSON