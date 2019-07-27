helm del --purge esphome
helm del --purge home-assistant

SERVICES='home-assistant esphome'
KUBE_RESOURCES='deployment ingress secrets service'

for service in $SERVICES; do
  for resource in $KUBE_RESOURCES; do
    kubectl delete $resource "${service}"
  done
done

./pv/remove_storage.sh
rm -rf /mnt/home-assistant
