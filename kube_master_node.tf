provider "aws" {
  
}

resource "aws_instance" "masternode" {

ami = "ami-0ad86651279e2c354"
tags = {
    Name="Kube Master" 

    }
instance_type = "t2.medium"
vpc_security_group_ids = [ aws_security_group.mastersg.id ]
key_name = "mykp"

user_data= <<-EOF
#!/bin/bash

yum update -y
yum install docker -y 
systemctl enable docker && systemctl start docker
echo "[kubernetes]

name=Kubernetes

baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64

enabled=1

gpgcheck=1

repo_gpgcheck=0

gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg

exclude=kube*" > /etc/yum.repos.d/kubernetes.repo
echo "net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1


sysctl --system
setenforce 0" > /etc/sysctl.d/k8s.conf
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable kubelet && systemctl start kubelet

kubeadm init --ignore-preflight-errors=all

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config


kubectl apply -f https://docs.projectcalico.org/v3.20/manifests/calico.yaml

EOF

}

resource "aws_security_group" "mastersg" {
  
  ingress {

    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
  }

  ingress {

    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
  }

  ingress {

    from_port = 6443
    to_port = 6443  
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
  }

  ingress {
   
    from_port = 10250
    to_port = 10250
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

 
}

resource "aws_key_pair" "mykp" {
key_name = "mykp"
public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
algorithm = "RSA"
rsa_bits  = 4096
}

resource "local_file" "tf-key" {
content  = tls_private_key.rsa.private_key_pem
filename = "mykp"
}


