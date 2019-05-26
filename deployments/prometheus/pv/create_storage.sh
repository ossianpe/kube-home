SERVICE='prometheus'
KUBE_RESOURCES='pv'
STORAGES='server pushgateway alertmanager'

DIR_PATH=$(echo ${0} | sed 's/\(.*\)\/.*/\1/')

for resource in $KUBE_RESOURCES; do
  for storage in $STORAGES; do
    kubectl create -f "${DIR_PATH}/${SERVICE}-${storage}-${resource}.yaml"
  done
done
