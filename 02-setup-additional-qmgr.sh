#!/bin/bash

# exit when any command fails
set -e

# allow this script to be run from other locations, despite the
#  relative file paths used in it
if [[ $BASH_SOURCE = */* ]]; then
  cd -- "${BASH_SOURCE%/*}/" || exit
fi

# escape sequences for colouring headings in the
#  script output
HIGHLIGHT_ON="\033[40m\033[1;33m"
HIGHLIGHT_OFF="\033[0m"


printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON Adding queue manager to the cluster                                   $HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"

printf "$HIGHLIGHT_ON> Creating configmap for the additional queue manager $HIGHLIGHT_OFF\n"
oc apply -f ./mq-resources-2/configmap-qm4.yaml

printf "$HIGHLIGHT_ON> Creating additional queue manager $HIGHLIGHT_OFF\n"
oc apply -f ./mq-resources-2/qmgr-qm4.yaml

printf "$HIGHLIGHT_ON> Waiting for queue manager to be ready $HIGHLIGHT_OFF\n"
wait_for_queue_manager () {
  queuemanagername=$1
  PHASE="Pending"
  while [ "$PHASE" != "Running" ]
  do
      PHASE=`oc get queuemanager -n uniform-cluster $queuemanagername -o jsonpath='{.status.phase}'`
      sleep 10
  done
}
wait_for_queue_manager uniform-cluster-qm4

printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON Updating JMS client applications                                      $HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"

printf "$HIGHLIGHT_ON> Updating CCDT with additional queue manager details $HIGHLIGHT_OFF\n"
oc apply -f ./test-app-resources-2/ccdt.yaml

printf "$HIGHLIGHT_ON> Rolling update of JMS apps $HIGHLIGHT_OFF\n"
version=$(oc get configmap ccdt -n uniform-cluster -o jsonpath='{.metadata.resourceVersion}')
# This restarts the JMS apps, so that the restarted app
#  can reflect changes to the CCDT ConfigMap.
#
# The restarts are performed in a rolling update, so there are always
#  some instances in a running state.
oc patch \
    deployment test-app-getter \
    -n uniform-cluster \
    -p '{"spec":{ "template":{ "metadata":{ "annotations": { "ccdt-version": "'$version'" }}}}}'
sleep 10
oc patch \
    deployment test-app-putter \
    -n uniform-cluster \
    -p '{"spec":{ "template":{ "metadata":{ "annotations": { "ccdt-version": "'$version'" }}}}}'


printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON Queue manager addition complete                                       $HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"
