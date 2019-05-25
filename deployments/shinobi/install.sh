# setup storage requirements
./pv/create_storage.sh

#SUPER_PASSWORD=password
#SUPER_PASSWORD_MD5=$(echo "$SUPER_PASSWORD" | md5sum | awk -F ' ' '{ print $1 }')
#sed -i "s/\(spass: \)\(.*\)/\1${SUPER_PASSWORD_MD5}/" values.yaml

MYSQL_PASSWORD=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
sed -i "s/\(mysqlPassword: \)\(.*\)/\1${MYSQL_PASSWORD}/" values.yaml

KEY_PASSWORD=$(cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 32 | head -n 1)
sed -i "s/\(key: \)\(.*\)/\1${KEY_PASSWORD}/" values.yaml

MOTION_PASSWORD=$(cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 32 | head -n 1)
sed -i "s/\(Motion: \)\(.*\)/\1${MOTION_PASSWORD}/" values.yaml

OPENCV_PASSWORD=$(cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 32 | head -n 1)
sed -i "s/\(OpenCV: \)\(.*\)/\1${OPENCV_PASSWORD}/" values.yaml

OPENALPR_PASSWORD=$(cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 32 | head -n 1)
sed -i "s/\(OpenALPR: \)\(.*\)/\1${OPENALPR_PASSWORD}/" values.yaml

helm install --name shinobi . --values values.yaml
