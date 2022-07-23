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
printf "$HIGHLIGHT_ON Building test apps                                                   $HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"

printf "$HIGHLIGHT_ON> Building the JMS apps jar $HIGHLIGHT_OFF\n"
cd mq-jms-ccdt
mvn package
cd ..

printf "$HIGHLIGHT_ON> Exposing the OpenShift Image Registry so a new test app image can be pushed to it $HIGHLIGHT_OFF\n"
oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge

printf "$HIGHLIGHT_ON> Build Docker image with the JMS apps jar $HIGHLIGHT_OFF\n"
image_registry_route="$(oc get routes -n openshift-image-registry -o custom-columns=:.spec.host --no-headers)"
docker login "$image_registry_route" -u oc -p "$(oc whoami -t)"
docker build --platform linux/amd64 -t "$image_registry_route"/uniform-cluster/jmstestapps:3 .

printf "$HIGHLIGHT_ON> Push JMS Docker image to the OpenShift Image Registry $HIGHLIGHT_OFF\n"
docker push "$image_registry_route"/uniform-cluster/jmstestapps:3

printf "$HIGHLIGHT_ON> Storing JMS test applications certificates in OpenShift $HIGHLIGHT_OFF\n"
oc create secret generic jms-client-truststore \
  --from-file=ca.jks=./certs-generation/certs/uniformcluster-ca.jks \
  --from-literal=password='passw0rd' \
  -n uniform-cluster --dry-run=client -oyaml | oc apply -f -
oc create secret generic jms-putter-keystore \
  --from-file=client.jks=./certs-generation/certs/uniformcluster-jms-putter.jks \
  --from-literal=password='passw0rd' \
  -n uniform-cluster --dry-run=client -oyaml | oc apply -f -
oc create secret generic jms-getter-keystore \
  --from-file=client.jks=./certs-generation/certs/uniformcluster-jms-getter.jks \
  --from-literal=password='passw0rd' \
  -n uniform-cluster --dry-run=client -oyaml | oc apply -f -


printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON Test apps built and prepared                                          $HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"
