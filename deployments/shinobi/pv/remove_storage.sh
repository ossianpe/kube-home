SERVICE='shinobi'
KUBE_RESOURCES='pv'
STORAGES='data mysql'

for resource in $KUBE_RESOURCES; do
  for storage in $STORAGES; do
    kubectl delete $resource "${SERVICE}-${storage}"
  done
done
