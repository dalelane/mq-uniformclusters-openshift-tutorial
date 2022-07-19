#!/bin/bash

#
# This script will display a constantly updating view of the number of
#  messages remaining on the test queue on each queue manager in
#  the cluster
#

get_curdepth () {
    QMGR=$1
    oc exec $QMGR -n uniform-cluster -it -- bash -c "echo \"dis ql(APPQ1) curdepth\" | runmqsc -e | grep CURDEPTH | awk -F\"[()]\" '{print \$2}'"
}

HIGHLIGHT_ON="\033[40m\033[1;33m"
HIGHLIGHT_OFF="\033[0m"

while true
    do
        qm1_msgs=$(get_curdepth 'uniform-cluster-qm1-ibm-mq-0')
        qm2_msgs=$(get_curdepth 'uniform-cluster-qm2-ibm-mq-0')
        qm3_msgs=$(get_curdepth 'uniform-cluster-qm3-ibm-mq-0')
        qm4_msgs=$(get_curdepth 'uniform-cluster-qm4-ibm-mq-0')
        clear
        printf "$HIGHLIGHT_ON=================================================$HIGHLIGHT_OFF\n"
        printf "$HIGHLIGHT_ON Messages on the APPQ1 queue instance hosted on: $HIGHLIGHT_OFF\n"
        printf "$HIGHLIGHT_ON=================================================$HIGHLIGHT_OFF\n"
        echo "QM1 - ${qm1_msgs}"
        echo "QM2 - ${qm2_msgs}"
        echo "QM3 - ${qm3_msgs}"
        echo "QM4 - ${qm4_msgs}"
    done
