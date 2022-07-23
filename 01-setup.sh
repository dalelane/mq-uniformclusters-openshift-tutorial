#!/bin/bash

# exit when any command fails
set -e

# allow this script to be run from other locations, despite the
#  relative file paths used in it
if [[ $BASH_SOURCE = */* ]]; then
  cd -- "${BASH_SOURCE%/*}/" || exit
fi

# check that we have an entitlement key that we can put in a secret
if [[ -z "$IBM_ENTITLEMENT_KEY" ]]; then
    echo "You must set an IBM_ENTITLEMENT_KEY environment variable" 1>&2
    echo "Create your entitlement key at https://myibm.ibm.com/products-services/containerlibrary" 1>&2
    echo "Set it like this:" 1>&2
    echo " export IBM_ENTITLEMENT_KEY=..." 1>&2
    exit 1
fi

# escape sequences for colouring headings in the
#  script output
HIGHLIGHT_ON="\033[40m\033[1;33m"
HIGHLIGHT_OFF="\033[0m"


printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON Initial prep / setup                                                  $HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"

printf "$HIGHLIGHT_ON> Creating namespace where the uniform cluster demo will run $HIGHLIGHT_OFF\n"
oc create namespace uniform-cluster --dry-run=client -o yaml | oc apply -f -

printf "$HIGHLIGHT_ON> Creating entitlement key for accessing MQ docker images $HIGHLIGHT_OFF\n"
oc create secret docker-registry ibm-entitlement-key \
    --docker-username=cp \
    --docker-password=$IBM_ENTITLEMENT_KEY \
    --docker-server=cp.icr.io \
    --namespace=uniform-cluster --dry-run=client -o yaml | oc apply -f -


printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON Creating the queue manager cluster                                    $HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"

printf "$HIGHLIGHT_ON> Creating certficates $HIGHLIGHT_OFF\n"
cd certs-generation
./generate.sh
cd ..

printf "$HIGHLIGHT_ON> Storing queue manager certificates in OpenShift $HIGHLIGHT_OFF\n"
oc create secret tls mq-server-tls -n uniform-cluster \
    --key="./certs-generation/certs/uniformcluster-mq-server.key" \
    --cert="./certs-generation/certs/uniformcluster-mq-server.crt" \
    --dry-run=client -oyaml | oc apply -f -
oc create secret generic mq-ca-tls -n uniform-cluster \
    --from-file=ca.crt=./certs-generation/certs/uniformcluster-ca.crt \
    --dry-run=client -oyaml | oc apply -f -

printf "$HIGHLIGHT_ON> Creating configmaps that define the queue manager cluster $HIGHLIGHT_OFF\n"
oc apply -f ./mq-resources/configmap-uniformcluster.yaml
oc apply -f ./mq-resources/configmap-common.yaml
oc apply -f ./mq-resources/configmap-qm1.yaml
oc apply -f ./mq-resources/configmap-qm2.yaml
oc apply -f ./mq-resources/configmap-qm3.yaml

printf "$HIGHLIGHT_ON> Creating queue managers $HIGHLIGHT_OFF\n"
oc apply -f ./mq-resources/qmgr-qm1.yaml
oc apply -f ./mq-resources/qmgr-qm2.yaml
oc apply -f ./mq-resources/qmgr-qm3.yaml

printf "$HIGHLIGHT_ON> Waiting for queue managers to be ready $HIGHLIGHT_OFF\n"
wait_for_queue_manager () {
  queuemanagername=$1
  PHASE="Pending"
  while [ "$PHASE" != "Running" ]
  do
      PHASE=`oc get queuemanager -n uniform-cluster $queuemanagername -o jsonpath='{.status.phase}'`
      sleep 10
  done
}
wait_for_queue_manager uniform-cluster-qm1
wait_for_queue_manager uniform-cluster-qm2
wait_for_queue_manager uniform-cluster-qm3

printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON Queue manager cluster ready                                           $HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"
