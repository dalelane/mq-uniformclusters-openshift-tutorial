#!/bin/bash

#
# This displays a constantly updating view of the instances of
#  the getter app, grouped by their status
#

HIGHLIGHT_ON="\033[40m\033[1;33m"
HIGHLIGHT_OFF="\033[0m"

while true
    do
        output=$(oc get pods -l app=jms-getter -n uniform-cluster --no-headers | sort -k3)
        clear
        printf "$HIGHLIGHT_ON------------------------------------------------------------------------$HIGHLIGHT_OFF\n"
        printf "$HIGHLIGHT_ON getter app pods                                                        $HIGHLIGHT_OFF\n"
        printf "$HIGHLIGHT_ON------------------------------------------------------------------------$HIGHLIGHT_OFF\n"
        echo "$output"
    done
