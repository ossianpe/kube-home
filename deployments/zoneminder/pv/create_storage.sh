NGINX_NAME='hass-nginx'
KUBE_RESOURCES='pv pvc'
STORAGES='config content backups mysql'

for resource in $KUBE_RESOURCES; do
  for storage in $STORAGES; do
    kubectl create -f "zoneminder-${storage}-${resource}.yaml"
  done
done
