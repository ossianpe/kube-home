echo 'Configuring PV for zm-mysql'
kubectl create -f pv/zoneminder-mysql-pv.yaml

MYSQL_DATABASE_NAME='zm'
sed -i "s/\(name: \)\(.*\)/\1\"${MYSQL_DATABASE_NAME}\"/" app/values.yaml
sed -i "s/\(mysqlDatabase:\)\(.*\)/\1 ${MYSQL_DATABASE_NAME}/" mysql/values.yaml

MYSQL_ROOT_PASSWORD=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
sed -i "s/\(rootPassword: \)\(.*\)/\1\"${MYSQL_ROOT_PASSWORD}\"/" app/values.yaml
sed -i "s/\(mysqlRootPassword:\)\(.*\)/\1 ${MYSQL_ROOT_PASSWORD}/" mysql/values.yaml

MYSQL_USER='zmuser'
sed -i "s/\(user: \)\(.*\)/\1\"${MYSQL_USER}\"/" app/values.yaml
sed -i "s/\(mysqlUser:\)\(.*\)/\1 ${MYSQL_USER}/" mysql/values.yaml

MYSQL_USER_PASSWORD=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
# Note: for some reason, changing this password does not work
MYSQL_USER_PASSWORD=zmpass
sed -i "s/\(password: \)\(.*\)/\1\"${MYSQL_USER_PASSWORD}\"/" app/values.yaml
sed -i "s/\(mysqlPassword:\)\(.*\)/\1 ${MYSQL_USER_PASSWORD}/" mysql/values.yaml

echo 'Installing zm-mysql'
helm install --name zm-mysql -f ./mysql/values.yaml ./mysql

# Wait for zm-mysql to come up to install zoneminder app
while true; do
  is_ready=$(kubectl get pods | grep zm-mysql | awk -F ' ' ' { print $3 } ')
  all_pods_ready=$(kubectl get pods | grep zm-mysql | awk -F ' ' ' { print $2 } ')
  initalized_pods="${all_pods_ready::1}"
  total_pods="${all_pods_ready: -1}"
  status_msg='Waiting for zm-mysql to become ready..'
  if [ "$is_ready" == 'Running' ]; then
    status_msg="Waiting for all pods (${all_pods_ready}) to become ready.."
    if [ "$initalized_pods" -eq "$total_pods" ]; then
      if ! [ -z "$all_pods_ready" ]; then
        break
      fi
    fi
  fi

  echo "$status_msg"
  sleep 3
done

MYSQL_DATABASE_HOST=$(kubectl get service zm-mysql --template={{.spec.clusterIP}})
sed -i "s/\(host: \)\(.*\)/\1\"${MYSQL_DATABASE_HOST}\"/" app/values.yaml

echo ''
echo 'Installing zoneminder app'
helm install --name zoneminder -f ./app/values.yaml ./app

# Wait for Zoneminder app to come up to run db init cmds
while true; do
  is_ready=$(kubectl get pods | grep zoneminder | awk -F ' ' ' { print $3 } ')
  all_pods_ready=$(kubectl get pods | grep zoneminder | awk -F ' ' ' { print $2 } ')
  initalized_pods="${all_pods_ready::1}"
  total_pods="${all_pods_ready: -1}"
  status_msg='Waiting for zoneminder to become ready..'
  if [ "$is_ready" == 'Running' ]; then
    status_msg="Waiting for all pods (${all_pods_ready}) to become ready.."
    if [ "$initalized_pods" -eq "$total_pods" ]; then
      if ! [ -z "$all_pods_ready" ]; then
        break
      fi
    fi
  fi

  echo "$status_msg"
  sleep 3
done

ZONEMINDER_POD_NAME=$(kubectl get pods | grep zoneminder | awk -F ' ' '{ print $1 }')

echo 'Injecting init db..'
kubectl exec \
  -it ${ZONEMINDER_POD_NAME} -- \
  bash -c "mysql \
            -h ${MYSQL_DATABASE_HOST} \
            -uroot \
            -p${MYSQL_ROOT_PASSWORD} \
            < /usr/share/zoneminder/db/zm_create.sql" \
            > /dev/null 2>&1

kubectl exec \
  -it ${ZONEMINDER_POD_NAME} -- \
  bash -c "mysql \
             -h ${MYSQL_DATABASE_HOST} \
             -uroot \
             -p${MYSQL_ROOT_PASSWORD} \
             -e \"grant lock tables,alter,drop,select,insert,update,delete,create,index,alter routine,create routine, trigger,execute on zm.* to 'zmuser'@localhost identified by 'zmpass';\"" \
             > /dev/null 2>&1
echo 'Finished deployment and setup of Zoneminder!'

