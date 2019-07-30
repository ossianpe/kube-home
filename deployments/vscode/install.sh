# setup storage requirements
./pv/create_storage.sh

NAMESPACE=default
sed -i "s/\(namespace: \)\(.*\)/\1${NAMESPACE}/" values.yaml

HASS_PASSWORD=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
sed -i "s/\(hassPassword: \)\(.*\)/\1${HASS_PASSWORD}/" values.yaml

KUBE_HOME_PASSWORD=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
sed -i "s/\(kubeHomePassword: \)\(.*\)/\1${KUBE_HOME_PASSWORD}/" values.yaml

helm install --name vscode . --values values.yaml --namespace $NAMESPACE
