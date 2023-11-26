#!/usr/bin/env bash
set -euo pipefail

exit_code=0

echo "--> Should allow containerd as container runtime when below k8s version 1.24"
export KUBELET_VERSION=v1.20.15-eks-ba74326
/etc/eks/bootstrap.sh \
  --b64-cluster-ca dGVzdA== \
  --apiserver-endpoint http://my-api-endpoint \
  --container-runtime containerd \
  test || exit_code=$?

if [[ ${exit_code} -ne 0 ]]; then
  echo "❌ Test Failed: expected a zero exit code but got '${exit_code}'"
  exit 1
fi

echo "--> Should have default container runtime when below k8s version 1.24"
export KUBELET_VERSION=v1.20.15-eks-ba74326
/etc/eks/bootstrap.sh \
  --b64-cluster-ca dGVzdA== \
  --apiserver-endpoint http://my-api-endpoint \
  test || exit_code=$?

if [[ ${exit_code} -ne 0 ]]; then
  echo "❌ Test Failed: expected a zero exit code but got '${exit_code}'"
  exit 1
fi

echo "--> Should allow containerd as container runtime when at or above k8s version 1.24"
export KUBELET_VERSION=v1.24.15-eks-ba74326
/etc/eks/bootstrap.sh \
  --b64-cluster-ca dGVzdA== \
  --apiserver-endpoint http://my-api-endpoint \
  --container-runtime containerd \
  test || exit_code=$?

if [[ ${exit_code} -ne 0 ]]; then
  echo "❌ Test Failed: expected a zero exit code but got '${exit_code}'"
  exit 1
fi

echo "--> Should have default container runtime when at or above k8s version 1.24"
export KUBELET_VERSION=v1.24.15-eks-ba74326
/etc/eks/bootstrap.sh \
  --b64-cluster-ca dGVzdA== \
  --apiserver-endpoint http://my-api-endpoint \
  test || exit_code=$?

if [[ ${exit_code} -ne 0 ]]; then
  echo "❌ Test Failed: expected a zero exit code but got '${exit_code}'"
  exit 1
fi
