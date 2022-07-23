#!/bin/bash

# exit when any command fails
set -e

echo "------------------------------------------------------------"
echo "Generating certificates for the MQ queue manager and clients"
echo "------------------------------------------------------------"

# prefix to use for names of generated files
export PREFIX=uniformcluster

# get the hostname used by the OpenShift console, which we'll use as the basis for
#  addresses to generate certificates for
consolehost=$(oc get route console -n openshift-console -ojsonpath='{.spec.host}')
openshifthost=${consolehost#*.}
export SAN_DNS="*.$openshifthost"
export COMMON_NAME="*.${openshifthost#*.}"

# hard-coded attributes for certificates - change these to suit your project
export ORGANISATION=dalelane
export COUNTRY=GB
export LOCALITY=Hursley
export STATE=Hampshire

# build the docker image that will be used to generate certs
#  (this is more convenient than asking you to install all the
#   dependencies you will need on your development machine)

docker build --platform linux/amd64 -t cert-generator image

# prepare folder where certs will be made available on the host
mkdir -p "$(pwd)/certs"

# run the certificate generator
docker run \
  -v "$(pwd)/certs:/certs" \
  -w /certs \
  --rm \
  --platform linux/amd64 \
  -e PREFIX=${PREFIX} \
  -e COMMON_NAME=${COMMON_NAME} \
  -e SAN_DNS=${SAN_DNS} \
  -e ORGANISATION=${ORGANISATION} \
  -e COUNTRY=${COUNTRY} \
  -e LOCALITY=${LOCALITY} \
  -e STATE=${STATE} \
  cert-generator \
  make -f /src/Makefile


docker run \
  -v "$(pwd)/certs:/certs" \
  -w /certs \
  --rm \
  --platform linux/amd64 \
  cert-generator \
  openssl x509 \
  -in ${PREFIX}-mq-server.crt \
  -text \
  -noout


echo "----------------------------------------------------------------------"
echo "Certificates have been generated in ./certs-generation/certs"
echo "----------------------------------------------------------------------"
