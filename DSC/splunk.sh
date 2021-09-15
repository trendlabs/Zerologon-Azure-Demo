#! /bin/bash
yum update -y 
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config && cat /etc/selinux/config
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
curl https://vnqradar.blob.core.windows.net/iso/splunk-8.2.2-87344edfcdb4-linux-2.6-x86_64.rpm -o /home/azureuser/splunk.rpm
systemctl stop firewalld
systemctl disable firewalld 
yum install -y yum-utils iproute-tc
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io
systemctl start docker
usermod -aG docker azureuser
cat <<EOF | tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
systemctl enable docker
systemctl daemon-reload
systemctl restart docker
docker run -d -p 8000:8000 -e SPLUNK_START_ARGS='--accept-license' -e SPLUNK_PASSWORD='Tr3ndM1cr02021#' splunk/splunk:latest