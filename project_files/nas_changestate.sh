#!/bin/bash

# Afficher l'exécution du script avec les arguments dans les logs Docker
echo "Exécution du script nas_changestate.sh avec les arguments : $@" >> /proc/1/fd/1

CONFIG_FILE="/usr/local/etc/devices.conf"
DEFAULT_TIMEOUT_ON=300  # Timeout par défaut pour l'allumage
DEFAULT_TIMEOUT_OFF=200  # Timeout par défaut pour l'extinction
SSH_OPTS=${SSH_OPTS:-"-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"}  # Options SSH par défaut

ping_device() {
    local ip=$1
    ping -c 1 -W 1 "$ip" > /dev/null 2>&1
    return $?
}

wait_for_ping() {
    local ip=$1
    local timeout=$2
    local start_time=$(date +%s)

    while true; do
        ping_device "$ip"
        if [ $? -eq 0 ]; then
            return 0
        fi
        local current_time=$(date +%s)
        if [ -z "$current_time" ] || [ -z "$start_time" ]; then
            return 1
        fi
        if [ $(($current_time - $start_time)) -ge $timeout ]; then
            return 1
        fi
        sleep 1
    done
}

wait_for_no_ping() {
    local ip=$1
    local timeout=$2
    local start_time=$(date +%s)

    while true; do
        ping_device "$ip"
        if [ $? -ne 0 ]; then
            return 0
        fi
        local current_time=$(date +%s)
        if [ -z "$current_time" ] || [ -z "$start_time" ]; then
            return 1
        fi
        if [ $(($current_time - $start_time)) -ge $timeout ]; then
            return 1
        fi
        sleep 1
    done
}

# Lecture des arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --device=*) DEVICE="${1#*=}"; shift 1;;
    *) ACTION="$1"; shift 1;;
  esac
done

if [ -z "$ACTION" ] || [ -z "$DEVICE" ]; then
    echo "Usage: $0 {on|off|getstatus} --device=device_name"
    exit 1
fi

liste_params=$(awk '/\[/{prefix=$0; next} $1{print prefix $0}' $CONFIG_FILE | grep "\[$DEVICE\]")

ip=$(echo "$liste_params" | grep 'ip=' | cut -d'=' -f2)
mac=$(echo "$liste_params" | grep 'mac=' | cut -d'=' -f2)
broadcast_ip=$(echo "$liste_params" | grep 'broadcast=' | cut -d'=' -f2)
ssh_user=$(echo "$liste_params" | grep 'ssh_user' | cut -d'=' -f2)
ssh_cert_path=$(echo "$liste_params" | grep 'ssh_cert_path=' | cut -d'=' -f2)
ssh_pass=$(echo "$liste_params" | grep 'ssh_pass=' | cut -d'=' -f2)
timeout_on=$(echo "$liste_params" | grep 'timeout_on=' | cut -d'=' -f2)
timeout_off=$(echo "$liste_params" | grep 'timeout_off=' | cut -d'=' -f2)
timeout_on=${timeout_on:-$DEFAULT_TIMEOUT_ON}
timeout_off=${timeout_off:-$DEFAULT_TIMEOUT_OFF}

# Afficher les paramètres relevés dans les logs Docker
{
echo "Paramètres pour $ :"
echo "IP : $ip"
echo "MAC : $mac"
echo "Adresse de diffusion : $broadcast_ip"
echo "Utilisateur SSH : $ssh_user"
echo "Certificat SSH : $ssh_cert_path"
echo "Mot de passe SSH : $ssh_pass"
echo "Timeout d'allumage : $timeout_on"
echo "Timeout d'extinction : $timeout_off"
} >> /proc/1/fd/1


case "$ACTION" in
  on)
      ping_device "$ip"
      if [ $? -eq 0 ]; then
          echo "Le périphérique $DEVICE est déjà allumé."
          exit 0
      fi

      wol $mac --host=${broadcast_ip:-192.168.1.255}
      echo "Tentative d'allumage du périphérique $DEVICE... Commande exécutée : wol $mac --host=${broadcast_ip:-192.168.1.255}"
      wait_for_ping "$ip" "$timeout_on"
      if [ $? -eq 0 ]; then
          echo "Le périphérique $DEVICE est maintenant allumé."
      else
          echo "Échec de l'allumage du périphérique $DEVICE après $timeout_on secondes."
      fi
      ;;
  off)
      ping_device "$ip"
      if [ $? -ne 0 ]; then
          echo "Le périphérique $DEVICE est déjà éteint ou injoignable."
          exit 0
      fi

      if [ -n "$ssh_pass" ]; then
          ssh_cmd="sshpass -p $ssh_pass ssh ${SSH_OPTS//\"} $ssh_user@$ip 'poweroff'"
      else
          ssh_cmd="ssh -i $ssh_cert_path ${SSH_OPTS//\"} $ssh_user@$ip 'poweroff'"
      fi

      eval "$ssh_cmd"
      echo "Tentative d'extinction du périphérique $DEVICE. Commande exécutée : $ssh_cmd"
      wait_for_no_ping "$ip" "$timeout_off"
      if [ $? -eq 0 ]; then
          echo "Le périphérique $DEVICE est maintenant éteint."
      else
          echo "Échec de l'extinction du périphérique $DEVICE après $timeout_off secondes."
      fi
      ;;
  getstatus)
      ping_device "$ip"
      if [ $? -eq 0 ]; then
          echo "Le périphérique $DEVICE est allumé."
      else
          echo "Le périphérique $DEVICE est injoignable/éteint."
      fi
      ;;
  *)
      echo "Usage: $0 {on|off|getstatus} --device=device_name"
      exit 1
      ;;
esac