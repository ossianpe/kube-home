# setup storage requirements
./pv/create_storage.sh

NAMESPACE=hass
sed -i "s/\(namespace: \)\(.*\)/\1${NAMESPACE}/" charts/home-assistant/values.yaml

MYSQL_DATABASE_NAME=hass
sed -i "s/\(mysqlDatabase: \)\(.*\)/\1${MYSQL_DATABASE_NAME}/" charts/mysql/values.yaml
sed -i "s/\(mysqlDatabase: \)\(.*\)/\1${MYSQL_DATABASE_NAME}/" charts/home-assistant/values.yaml

MYSQL_USERNAME=admin
sed -i "s/\(mysqlUser: \)\(.*\)/\1${MYSQL_USERNAME}/" charts/mysql/values.yaml
sed -i "s/\(mysqlUser: \)\(.*\)/\1${MYSQL_USERNAME}/" charts/home-assistant/values.yaml

MYSQL_PASSWORD=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
sed -i "s/\(mysqlPassword: \)\(.*\)/\1${MYSQL_PASSWORD}/" charts/mysql/values.yaml
sed -i "s/\(mysqlPassword: \)\(.*\)/\1${MYSQL_PASSWORD}/" charts/home-assistant/values.yaml

CONFIGURATOR_USERNAME=admin
sed -i "s/\(configurator_username: \)\(.*\)/\1${CONFIGURATOR_USERNAME}/" charts/home-assistant/values.yaml

CONFIGURATOR_PASSWORD=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
sed -i "s/\(configurator_password: \)\(.*\)/\1${CONFIGURATOR_PASSWORD}/" charts/home-assistant/values.yaml

DASSHIO_TOKEN=$(cat .secrets/DASSHIO_TOKEN)
sed -i "s/\(token: \)\(.*\)/\1${DASSHIO_TOKEN}/" charts/dasshio/values.yaml

helm install --name mysql charts/mysql --values charts/mysql/values.yaml --namespace $NAMESPACE
helm install --name home-assistant charts/home-assistant --values charts/home-assistant/values.yaml --namespace $NAMESPACE
helm install --name esphome charts/esphome --values charts/esphome/values.yaml --namespace $NAMESPACE
helm install --name dasshio charts/dasshio --values charts/dasshio/values.yaml --namespace $NAMESPACE
