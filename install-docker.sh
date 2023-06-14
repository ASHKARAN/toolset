if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

yes | apt update
yes | apt upgrade
echo  ===================== STAGE 1 [remove old docker]  =====================
yes | apt-get remove docker docker-engine docker.io containerd runc

echo  ===================== STAGE 2 [pre-install]  =====================
yes | apt-get install \
    ca-certificates \
    curl \
    gnupg
echo  ===================== STAGE 3  =====================
yes | apt-get update

echo  ===================== STAGE 4  =====================
yes | apt-get install \
    ca-certificates \
    curl \
    gnupg

echo  ===================== STAGE 5  =====================
mkdir -m 0755 -p /etc/apt/keyrings


echo  ===================== STAGE 6  =====================
curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  gpg --dearmor -o /etc/apt/keyrings/docker.gpg


echo  ===================== STAGE 6  =====================

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
   tee /etc/apt/sources.list.d/docker.list > /dev/null


echo  ===================== STAGE 7  =====================
apt-get update

echo  ===================== STAGE 8  =====================

yes | chmod a+r /etc/apt/keyrings/docker.gpg


echo  ===================== STAGE 9  =====================

apt-get update



echo  ===================== STAGE 10 [installing docker]  =====================

yes | apt  install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


yes | apt --fix-broken install

echo  ===================== STAGE 11 [non-root docker]  =====================


usermod -aG docker $USER 
newgrp docker


echo  ===================== STAGE 12 [install docker compose]  =====================
yes | apt  install docker-compose


