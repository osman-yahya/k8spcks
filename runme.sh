#!/bin/bash

# Hata ayıklama için (isteğe bağlı)
set -e

echo "Sistem paketlerini güncelliyoruz..."
sudo apt update && sudo apt upgrade -y

echo "Gerekli bağımlılıkları yüklüyoruz..."
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

# Kubernetes GPG anahtarını ekle
echo "Kubernetes için GPG anahtarı ekleniyor..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Kubernetes repo ekle
echo "Kubernetes reposu ekleniyor..."
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

# Paketleri tekrar güncelle
sudo apt-get update

# Kubernetes araçlarını yükle
echo "Kubernetes bileşenleri yükleniyor..."
sudo apt-get install -y kubelet kubeadm kubectl
sudo systemctl enable --now kubelet

# Docker GPG anahtarını ekle
echo "Docker için GPG anahtarı ekleniyor..."
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Docker repo ekle
echo "Docker reposu ekleniyor..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Paketleri tekrar güncelle
sudo apt-get update

# Docker ve containerd yükle
echo "Docker ve containerd yükleniyor..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Containerd servisini başlat ve kontrol et
echo "Containerd başlatılıyor..."
sudo systemctl enable --now containerd
sudo systemctl status containerd --no-pager

# Güvenlik duvarında 6443 portunu aç (Kubernetes API server için)
echo "Güvenlik duvarı güncelleniyor..."
sudo ufw allow 6443/tcp
sudo ufw reload

# Bağlantıları kontrol et
echo "Kurulum tamamlandı, bağlantılar kontrol ediliyor..."
kubectl version --client
docker --version
containerd --version

echo "Kurulum başarıyla tamamlandı! Osmandan kolay gelsin!"
