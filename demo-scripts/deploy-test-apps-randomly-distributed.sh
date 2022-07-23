#!/bin/bash

# allow this script to be run from other locations, despite the
#  relative file paths used in it
if [[ $BASH_SOURCE = */* ]]; then
  cd -- "${BASH_SOURCE%/*}/" || exit
fi

HIGHLIGHT_ON="\033[40m\033[1;33m"
HIGHLIGHT_OFF="\033[0m"

printf "$HIGHLIGHT_ON--------------------------------------------$HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON deploying apps (random initial connection) $HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON--------------------------------------------$HIGHLIGHT_OFF\n"
oc apply -f ../test-app-resources/ccdt-randomly-distributed.yaml
oc apply -f ../test-app-resources/deploy-getter.yaml
oc apply -f ../test-app-resources/deploy-putter.yaml
