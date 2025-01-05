# Image de base
FROM php:8.1-alpine

# Ajout du dépôt testing (pour wol), installer les dépendances, puis supprimer le dépôt testing 
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
  apk add --no-cache bash openssh wol sshpass && \
  sed -i '/edge\/testing/d' /etc/apk/repositories

# Copier les fichiers
COPY docker_files/nas_changestate.sh /usr/local/bin/nas_changestate.sh
COPY docker_files/devices.conf /usr/local/etc/devices.conf
COPY docker_files/nas_control.php /var/www/html/nas_control.php
COPY docker_files/index.php /var/www/html/index.php
COPY docker_files/router.php /var/www/html/router.php

# Ajuster les permissions
RUN chmod +x /usr/local/bin/nas_changestate.sh

# Exposer le port 80
EXPOSE 80

# Commande d'entrée
CMD ["php", "-S", "0.0.0.0:80", "-t", "/var/www/html"]
