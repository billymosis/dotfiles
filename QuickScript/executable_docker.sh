echo "starting postgresql service"
systemctl start docker.service
systemctl start containerd.service
echo "postgresql service successfully started"
