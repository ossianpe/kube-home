SERVICE='grafana'
KUBE_RESOURCES='pv'

for resource in $KUBE_RESOURCES; do
  kubectl delete $resource "${SERVICE}"
done
