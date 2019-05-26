# setup storage requirements
./pv/create_storage.sh

#SUPER_PASSWORD=password
#SUPER_PASSWORD_MD5=$(echo "$SUPER_PASSWORD" | md5sum | awk -F ' ' '{ print $1 }')
#sed -i "s/\(spass: \)\(.*\)/\1${SUPER_PASSWORD_MD5}/" values.yaml

#PASSWORD_KEY=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
#sed -i "s/\(passwordKey: \)\(.*\)/\1${PASSWORD_KEY}/" values.yaml

SMTP_PASSWORD=$(cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 32 | head -n 1)
sed -i "s/\(smtpPasswordKey: \)\(.*\)/\1${SMTP_PASSWORD}/" values.yaml

helm install --name grafana . --values values.yaml
