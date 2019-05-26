SERVICE='prometheus'
KUBE_RESOURCES='pv'
STORAGES='server pushgateway alertmanager'

for resource in $KUBE_RESOURCES; do
  for storage in $STORAGES; do
    kubectl delete $resource "${SERVICE}-${storage}"
  done
done
