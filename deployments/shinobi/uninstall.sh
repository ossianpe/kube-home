helm del --purge shinobi
./pv/remove_storage.sh

echo "Removing all data in ${PV_PATH}.."
rm -rf '/mnt/video/shinobi'
rm -rf '/mnt/shinobi'
