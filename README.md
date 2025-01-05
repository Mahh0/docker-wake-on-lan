# Docker Wake-on-LAN

Ce projet permet de gérer l'allumage, l'extinction et l'état des appareils via des commandes Wake-on-LAN et SSH dans un conteneur Docker.

## Pré-requis

1. **Docker** et **Docker Compose** doivent être installés sur votre système. Si ce n'est pas déjà fait, vous pouvez les installer en suivant les instructions sur le site officiel de Docker :
   - [Installer Docker](https://docs.docker.com/get-docker/)
   - [Installer Docker Compose](https://docs.docker.com/compose/install/)

2. **Configurer les paramètres du noyau Linux** pour permettre le broadcast des paquets Wake-on-LAN. Exécutez les commandes suivantes pour configurer les paramètres requis :

   ```bash
   sudo sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=0
   sudo sysctl -w net.ipv4.conf.all.bc_forwarding=1
   sudo sysctl -w net.ipv4.conf.<interface>.bc_forwarding=1
   ```
   Pensez à remplacer <interface> par l'interface réseau correspondante. 
   
   Pour rendre ces changements persistants après un redémarrage, ajoutez les lignes correspondantes dans un fichier de configuration dans '/etc/sysctl.d/', comme ceci (attention j'ai pas testé j'ai généré ça avec Copilot) :
   ```bash
   echo "net.ipv4.icmp_echo_ignore_broadcasts=0" | sudo tee -a /etc/sysctl.d/99-custom.conf
   echo "net.ipv4.conf.all.bc_forwarding=1" | sudo tee -a /etc/sysctl.d/99-custom.conf
   echo "net.ipv4.conf.<interface>.bc_forwarding=1" | sudo tee -a /etc/sysctl.d/99-custom.conf
   ```
   
## Installation
1. Cloner le dépot :
  ```bash
  git clone https://github.com/TON_UTILISATEUR_GITHUB/docker-wake-on-lan.git
  cd docker-wake-on-lan
  ```
  
2. Modifiez le fichier devices.conf pour ajouter vos appareils. Exemple de fichier conf :
  ```txt
[device1]
name=NAS
ip=192.168.1.160
mac=00:08:9b:bf:66:10
broadcast=192.168.1.255
ssh_user=admin
ssh_pass=monmotdepasse
timeout_on=300
timeout_off=200

[device2]
name=Server
ip=192.168.1.161
mac=00:11:22:33:44:55
broadcast=192.168.1.255
ssh_user=root
ssh_cert_path=/root/.ssh/id_rsa
timeout_on=500
timeout_off=400
  ```
  
3. Ajoutez, si nécessaire, la clé privée nécessaire pour se connecter aux appareils via SSH dans le répertoire docker_files/private_keys.

4. Construisez et démarrez le conteneur Docker :
  ```bash
  docker-compose up --build
  ```
  
## Utilisation
1. Utilisation via outil externe ("API")
- Pour allumer un appareil :
  ```bash
  http://<adresse_ip_serveur>:8080/nas_control.php?action=on&device=device1
  ```
  
- Pour éteindre un appareil :
  ```bash
  http://<adresse_ip_serveur>:8080/nas_control.php?action=off&device=device1
  ```
  
- Pour vérifier l'état d'un appareil :
  ```bash
  http://<adresse_ip_serveur>:8080/nas_control.php?action=getstatus&device=device1
  ```
  
2. Interface graphique : disponible sur http://<adresse_ip_serveur>:8080/index.php
