# setup storage requirements
#./pv/create_storage.sh

#PASSWORD_KEY=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
#sed -i "s/\(passwordKey: \)\(.*\)/\1${PASSWORD_KEY}/" values.yaml

helm install --name kubernetes-dashboard . --values values.yaml --namespace kube-system

token_secret_name=$(kubectl -n kube-system get secret | grep replicaset-controller-token | awk -F ' ' '{ print $1 }')
token_value="$(kubectl -n kube-system describe secrets ${token_secret_name} | tail -n 1 | awk -F ' ' '{ print $2 }')"

echo "Please use the following token in the webUI to allow access to Kubernetes cluster:

${token_value}"
