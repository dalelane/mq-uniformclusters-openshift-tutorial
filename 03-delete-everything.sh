#!/bin/bash

# exit when any command fails
set -e

# allow this script to be run from other locations, despite the
#  relative file paths used in it
if [[ $BASH_SOURCE = */* ]]; then
  cd -- "${BASH_SOURCE%/*}/" || exit
fi

oc delete --ignore-not-found=true -f ./test-app-resources
oc delete --ignore-not-found=true -f ./mq-resources-2
oc delete --ignore-not-found=true -f ./mq-resources

oc delete ns uniform-cluster  --ignore-not-found=true

rm -rfv ./certs-generation/certs


HIGHLIGHT_ON="\033[40m\033[1;33m"
HIGHLIGHT_OFF="\033[0m"
printf "$HIGHLIGHT_ON> Demo deleted $HIGHLIGHT_OFF\n"
