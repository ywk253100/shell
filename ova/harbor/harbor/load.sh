#!/bin/bash

echo "Loading images..."
basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
docker load -i $basedir/harbor*.tgz