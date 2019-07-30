# setup storage requirements
./pv/create_storage.sh

NAMESPACE=default
sed -i "s/\(namespace: \)\(.*\)/\1${NAMESPACE}/" values.yaml

helm install --name vscode . --values values.yaml --namespace $NAMESPACE
