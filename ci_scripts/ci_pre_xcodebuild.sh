#!/bin/sh

set -e

echo "Stage: PRE-Xcode Build is starting ..."

cd ../Dialogue/

touch apikey.env
echo $API_KEY > apikey.env

echo "Stage: PRE-Xcode Build is DONE ..."

exit 0
