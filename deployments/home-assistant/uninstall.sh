clean="$1"

helm del --purge hass-dasshio
helm del --purge hass-esphome
helm del --purge hass
helm del --purge hass-mysql
helm del --purge hass-nginx-ingress
helm del --purge hass-duckdns

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
