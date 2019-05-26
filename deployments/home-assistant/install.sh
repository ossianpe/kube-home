# setup storage requirements
./pv/create_storage.sh

#PASSWORD_KEY=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
#sed -i "s/\(passwordKey: \)\(.*\)/\1${PASSWORD_KEY}/" values.yaml

helm install --name home-assistant . --values values.yaml
