#!/bin/bash

#
# This script will display a constantly updating view of the number of getter apps
#  connected to each queue manager
#

oc exec uniform-cluster-qm1-ibm-mq-0 -n uniform-cluster -it -- bash -c "while true; \
    do \
        apstatus=\$(echo \"DIS APSTATUS('test-getter') TYPE(qmgr) QMNAME ACTIVE COUNT\" | runmqsc -e | grep COUNT | sort -b -n -k 2.10,2.11 | sed -e 's/              //'  ); \
        printf \"\033[H\033[2J\"; \
        printf \"\033[40m\033[1;33m=================================================\033[0m\\n\"; \
        printf \"\033[40m\033[1;33m test-getter app instances assigned to each qmgr \033[0m\\n\"; \
        printf \"\033[40m\033[1;33m=================================================\033[0m\\n\"; \
        printf \"\$apstatus\\n\"; \
    done"
