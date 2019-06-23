# setup storage requirements
#./pv/create_storage.sh

ADMIN_PASSWORD=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
sed -i "s/\(adminPassword: \)\(.*\)/\1${ADMIN_PASSWORD}/" kube-prometheus/charts/grafana/values.yaml

helm install --name prometheus-operator prometheus-operator --values prometheus-operator/values.yaml --namespace monitoring
helm install --name kube-prometheus kube-prometheus --values kube-prometheus/values.yaml --namespace monitoring

echo "Grafana password is: $ADMIN_PASSWORD"
