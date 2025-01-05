# Docker Wake-on-LAN

Ce projet permet de g�rer l'allumage, l'extinction et l'�tat des appareils via des commandes Wake-on-LAN et SSH dans un conteneur Docker.

## Pr�-requis

1. **Docker** et **Docker Compose** doivent �tre install�s sur votre syst�me. Si ce n'est pas d�j� fait, vous pouvez les installer en suivant les instructions sur le site officiel de Docker :
   - [Installer Docker](https://docs.docker.com/get-docker/)
   - [Installer Docker Compose](https://docs.docker.com/compose/install/)

2. **Configurer les param�tres du noyau Linux** pour permettre le broadcast des paquets Wake-on-LAN. Ex�cutez les commandes suivantes pour configurer les param�tres requis :

   ```bash
   sudo sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=0
   sudo sysctl -w net.ipv4.conf.all.bc_forwarding=1
   sudo sysctl -w net.ipv4.conf.<interface>.bc_forwarding=1
   ```
   Pensez � remplacer <interface> par l'interface r�seau correspondante. 
   
   Pour rendre ces changements persistants apr�s un red�marrage, ajoutez les lignes correspondantes dans un fichier de configuration dans '/etc/sysctl.d/', comme ceci :
   ```bash
   echo "net.ipv4.icmp_echo_ignore_broadcasts=0" | sudo tee -a /etc/sysctl.d/99-custom.conf
   echo "net.ipv4.conf.all.bc_forwarding=1" | sudo tee -a /etc/sysctl.d/99-custom.conf
   echo "net.ipv4.conf.docker0.bc_forwarding=1" | sudo tee -a /etc/sysctl.d/99-custom.conf
   ```
   
## Installation
1. Cloner le d�pot :
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
  
3. Ajoutez, si n�cessaire, la cl� priv�e n�cessaire pour se connecter aux appareils via SSH dans le r�pertoire docker_files/private_keys.

4. Construisez et d�marrez le conteneur Docker :
  ```bash
  docker-compose up --build
  ```
  
## Utilisation
1. Utilisation via outil externe ("API")
- Pour allumer un appareil :
  ```bash
  http://<adresse_ip_serveur>:8080/nas_control.php?action=on&device=device1
  ```
  
- Pour �teindre un appareil :
  ```bash
  http://<adresse_ip_serveur>:8080/nas_control.php?action=off&device=device1
  ```
  
- Pour v�rifier l'�tat d'un appareil :
  ```bash
  http://<adresse_ip_serveur>:8080/nas_control.php?action=getstatus&device=device1
  ```
  
2. Interface graphique : disponible sur http://<adresse_ip_serveur>:8080/index.php
