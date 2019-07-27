clean="$1"

helm del --purge dasshio
helm del --purge esphome
helm del --purge home-assistant
helm del --purge mysql

SERVICES='home-assistant esphome'
KUBE_RESOURCES='deployment ingress secrets service'

if ! [ -z "$clean" ]; then
  for service in $SERVICES; do
    for resource in $KUBE_RESOURCES; do
      kubectl delete $resource "${service}" -n hass
    done
  done
fi

./pv/remove_storage.sh
rm -rf /mnt/home-assistant/mysql
