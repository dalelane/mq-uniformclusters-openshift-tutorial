#!/bin/bash

HIGHLIGHT_ON="\033[40m\033[1;33m"
HIGHLIGHT_OFF="\033[0m"

printf "$HIGHLIGHT_ON--------------------------------------$HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON scaling getter apps  -- 30 instances $HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON--------------------------------------$HIGHLIGHT_OFF\n"
oc scale deploy -n uniform-cluster test-app-getter --replicas=30
