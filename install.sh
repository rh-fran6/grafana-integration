#!/bin/bash

export GRAFANA_NAMESPACE=grafana-operator

set -eo pipefail

export GRAFANA_NAMESPACE="grafana-operator"


echo "---> Creating Namespace $GRAFANA_NAMESPACE..."
cat <<EOF | oc apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: $GRAFANA_NAMESPACE
  labels:
    openshift.io/cluster-monitoring: "true"
EOF

# Create OperatorGroup
echo "---> Creating Grafana Operator Group called ${CLUSTER_NAME}-grafana-operator..."
cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: "${CLUSTER_NAME}-grafana-operator"
  namespace: $GRAFANA_NAMESPACE 
EOF

# Create Subscription
echo "---> Creating Grafana Subscription called ${CLUSTER_NAME}-grafana-operator..."
cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: "${CLUSTER_NAME}-grafana-operator"
  namespace: $GRAFANA_NAMESPACE
spec:
  channel: "v5"
  installPlanApproval: Automatic
  name: grafana-operator
  source: community-operators
  sourceNamespace: openshift-marketplace
EOF

echo "--> Waiting for Grafana Operator to be ready"

while ! kubectl -n $GRAFANA_NAMESPACE get pods | grep grafana-operator-controller 2> /dev/null > /dev/null; do
  echo waiting...
  sleep 1
done




