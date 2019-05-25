SERVICE='shinobi'
KUBE_RESOURCES='pv'
STORAGES='data mysql'

DIR_PATH=$(echo ${0} | sed 's/\(.*\)\/.*/\1/')

for resource in $KUBE_RESOURCES; do
  for storage in $STORAGES; do
    kubectl create -f "${DIR_PATH}/${SERVICE}-${storage}-${resource}.yaml"
  done
done
