helm del --purge home-assistant

SERVICE='home-assistant'
KUBE_RESOURCES='deployment ingress secrets service'

for resource in $KUBE_RESOURCES; do
  kubectl delete $resource "${SERVICE}"
  kubectl delete $resource "${SERVICE}"-configurator
done

./pv/remove_storage.sh
rm -rf /mnt/homeassistant
