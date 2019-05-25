echo 'Uninstalling zoneminder'
helm del --purge zoneminder
echo 'Unstall zm-mysql? (y/n)'
read command
if [ "$command" == 'y' ]; then
  helm del --purge zm-mysql
  echo 'Uninstalled zm-mysql'
  echo 'Wipe zm-mysql storage too? (y/n)'
  read command2
  if [ "$command2" == 'y' ]; then
    kubectl delete pv zm-mysql
    zm_mysql_path='/mnt/zoneminder/mysql'
    rm -rf "${zm_mysql_path}"
    echo "Deleted data in ${zm_mysql_path}"
  fi
fi
