SERVICE='home-assistant'
KUBE_RESOURCES='pv'
STORAGES=''

DIR_PATH=$(echo ${0} | sed 's/\(.*\)\/.*/\1/')

for resource in $KUBE_RESOURCES; do
  kubectl create -f "${DIR_PATH}/${SERVICE}-${resource}.yaml"
done
