SERVICE='home-assistant'
KUBE_RESOURCES='pvc pv'
STORAGES='data config'

DIR_PATH=$(echo ${0} | sed 's/\(.*\)\/.*/\1/')

for resource in $KUBE_RESOURCES; do
  for storage in $STORAGES; do
    kubectl delete $resource "${SERVICE}-${storage}"
  done
done
