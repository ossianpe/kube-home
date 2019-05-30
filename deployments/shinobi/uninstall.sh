helm del --purge shinobi
./pv/remove_storage.sh
PV_PATH='/mnt/video/shinobi/'
echo "Removing all data in ${PV_PATH}.."
rm -rf "$PV_PATH"
