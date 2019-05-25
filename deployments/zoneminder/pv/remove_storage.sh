NGINX_NAME='hass-nginx'
KUBE_RESOURCES='pvc pv'
STORAGES='config content backups mysql'

for resource in $KUBE_RESOURCES; do
  for storage in $STORAGES; do
    kubectl delete $resource "zoneminder-${storage}"
  done
done
