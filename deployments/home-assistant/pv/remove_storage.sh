SERVICE='home-assistant'
KUBE_RESOURCES='pvc pv'

for resource in $KUBE_RESOURCES; do
  kubectl delete $resource "${SERVICE}"
done
