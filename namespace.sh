#! /bin/bash
set -e
set -o pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 namespace-name"
    exit 1
fi

NAMESPACE=$1

CPU=1
MEMORY="1G"
LIMIT_CPU="$((2 * $CPU))"

kubectl apply --record --filename=- <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: $NAMESPACE
  labels:
    name: $NAMESPACE
  annotations:
    appstore.uninett.no/domains: apps.stack.it.ntnu.no

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
    name: default-deny
    namespace: $NAMESPACE
spec:
    podSelector:
      matchLabels: {}
    policyTypes:
    - Ingress

---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: quota
  namespace: $NAMESPACE
spec:
  hard:
    requests.cpu: "$CPU"
    requests.memory: $MEMORY
    limits.cpu: "$LIMIT_CPU"
    limits.memory: $MEMORY
    configmaps: "100"
    services: "100"
    secrets: "100"


---
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
  namespace: $NAMESPACE
spec:
  limits:
  - defaultRequest:
      cpu: 50m
      memory: 50Mi
    default:
      cpu: 150m
      memory: 100Mi
    type: Container

EOF
echo "Namespace: $NAMESPACE has been created with PVC"
