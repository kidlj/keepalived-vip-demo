# -*- mode: ruby -*-
# vi: set ft=ruby :

servers = [
    {
        :name => "keepalived-master",
        :type => "master",
        :box => "centos/7",
        :eth1 => "172.16.200.20",
        :mem => "2048",
        :cpu => "6"
    },
    {
        :name => "keepalived-node1",
        :type => "node",
        :box => "centos/7",
        :eth1 => "172.16.200.21",
        :mem => "1024",
        :cpu => "6"
    },
    {
        :name => "keepalived-node2",
        :type => "node",
        :box => "centos/7",
        :eth1 => "172.16.200.22",
        :mem => "1024",
        :cpu => "6"
    }
]

# This script to install k8s using kubeadm will get executed after a box is provisioned
$configureBox = <<-SCRIPT

# ensure kube-proxy ipvs mode
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4

cat <<EOF > /etc/modules-load.d/ipvs.conf
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack_ipv4
EOF

systemctl stop firewalld
systemctl disable firewalld
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

# set yum proxy
echo "proxy=http://172.16.200.1:1080" >> /etc/yum.conf

# install docker
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce-18.06.3.ce-3.el7
systemctl start docker
systemctl enable docker

# set up docker proxy
mkdir -p /etc/systemd/system/docker.service.d/
cat <<EOF > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://172.16.200.1:1080"
Environment="HTTPS_PROXY=http://172.16.200.1:1080"
EOF

systemctl daemon-reload
systemctl restart docker

# run docker commands as vagrant user (sudo not required)
usermod -aG docker vagrant

# setup kubernetes repo
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum makecache fast

# install kubeadm
# get canonical versions: curl -s https://packages.cloud.google.com/apt/dists/kubernetes-xenial/main/binary-amd64/Packages | grep Version | awk '{print $2}'
KUBE_VERSION=1.12.6
yum install -y kubelet-$KUBE_VERSION kubectl-$KUBE_VERSION kubeadm-$KUBE_VERSION kubernetes-cni-0.6.0

systemctl enable kubelet

# kubelet requires swap off
swapoff -a

# keep swap off after reboot
# TODO: sadly, this won't work. you have to do this manually after provisioning.
sed -i '/ swap / s/^(.*)$/#\1/g' /etc/fstab

# post-working
yum install -y telnet vim bind-utils tcpdump net-tools mtr
SCRIPT

Vagrant.configure("2") do |config|

    servers.each do |opts|
        config.vm.define opts[:name] do |config|
            config.vm.box = opts[:box]
            config.vm.hostname = opts[:name]
            config.vm.network :private_network, ip: opts[:eth1]

            config.vm.provider "virtualbox" do |v|
                v.gui = false
                v.name = opts[:name]
                v.memory = opts[:mem]
                v.cpus = opts[:cpu]
            end

            # we cannot use this because we can't install the docker version we want - https://github.com/hashicorp/vagrant/issues/4871
            #config.vm.provision "docker"

            config.vm.provision "shell", inline: $configureBox, args: opts[:eth1]

        end

    end

end 
