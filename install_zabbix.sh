#!/bin/bash

################################################################################
# Script d'installation automatisée de Zabbix 7.4 sur Debian
# Version: 1.0
# Description: Ce script automatise l'installation complète de Zabbix 7.4
#              incluant MariaDB, Apache, PHP et toutes les dépendances
################################################################################

set -e  # Arrêt du script en cas d'erreur

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fichier de log
LOG_FILE="/var/log/zabbix_installation.log"

################################################################################
# Fonctions utilitaires
################################################################################

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERREUR]${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

warning() {
    echo -e "${YELLOW}[ATTENTION]${NC} $1" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "Ce script doit être exécuté en tant que root ou avec sudo"
    fi
}

check_debian() {
    if [ ! -f /etc/debian_version ]; then
        error "Ce script est conçu pour Debian. Votre système n'est pas compatible."
    fi
    log "Système Debian détecté: $(cat /etc/debian_version)"
}

################################################################################
# Configuration réseau
################################################################################

detect_network_interface() {
    # Détecte l'interface réseau principale (exclut loopback)
    INTERFACES=$(ip -o link show | awk -F': ' '{print $2}' | grep -v "lo" | grep -v "@")
    
    if [ -z "$INTERFACES" ]; then
        error "Aucune interface réseau détectée"
    fi
    
    # Si plusieurs interfaces, demander à l'utilisateur
    INTERFACE_COUNT=$(echo "$INTERFACES" | wc -l)
    if [ "$INTERFACE_COUNT" -gt 1 ]; then
        echo ""
        echo "Interfaces réseau détectées:"
        echo "$INTERFACES" | nl
        read -p "Sélectionnez le numéro de l'interface à configurer: " INTERFACE_NUM
        NETWORK_INTERFACE=$(echo "$INTERFACES" | sed -n "${INTERFACE_NUM}p")
    else
        NETWORK_INTERFACE=$(echo "$INTERFACES" | head -n 1)
    fi
    
    info "Interface sélectionnée: $NETWORK_INTERFACE"
}

show_current_network_config() {
    log "Configuration réseau actuelle:"
    echo ""
    ip addr show "$NETWORK_INTERFACE" | grep -E "inet |ether " || true
    echo ""
    echo "Passerelle actuelle:"
    ip route | grep default || echo "Aucune passerelle configurée"
    echo ""
    echo "DNS actuels:"
    cat /etc/resolv.conf | grep nameserver || echo "Aucun DNS configuré"
    echo ""
}

configure_static_network() {
    log "Configuration du réseau statique..."
    
    detect_network_interface
    show_current_network_config
    
    echo ""
    read -p "Voulez-vous configurer une IP statique? (o/N): " CONFIGURE_NETWORK
    
    if [[ ! "$CONFIGURE_NETWORK" =~ ^[oO]$ ]]; then
        warning "Configuration réseau ignorée - continuant avec la configuration actuelle"
        return 0
    fi
    
    # Demander les informations réseau
    read -p "Adresse IP statique (ex: 192.168.1.100): " STATIC_IP
    read -p "Masque de sous-réseau (ex: 255.255.255.0 ou 24): " NETMASK
    read -p "Passerelle (ex: 192.168.1.1): " GATEWAY
    read -p "DNS primaire (ex: 8.8.8.8): " DNS1
    read -p "DNS secondaire (ex: 8.8.4.4) [optionnel]: " DNS2
    
    # Validation basique
    if [ -z "$STATIC_IP" ] || [ -z "$NETMASK" ] || [ -z "$GATEWAY" ] || [ -z "$DNS1" ]; then
        error "Tous les champs obligatoires doivent être renseignés"
    fi
    
    # Conversion du masque si nécessaire (255.255.255.0 -> 24)
    if [[ "$NETMASK" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        # Convertir le masque décimal en CIDR
        CIDR=$(ipcalc "$STATIC_IP" "$NETMASK" 2>/dev/null | grep "Netmask:" | awk '{print $4}' || echo "24")
        if [ -z "$CIDR" ]; then
            CIDR="24"
            warning "Impossible de convertir le masque, utilisation de /24 par défaut"
        fi
    else
        CIDR="$NETMASK"
    fi
    
    # Détecter le système de configuration réseau (Netplan ou interfaces)
    if [ -d "/etc/netplan" ] && command -v netplan &> /dev/null; then
        configure_netplan
    else
        configure_interfaces
    fi
    
    log "Configuration réseau appliquée avec succès"
    info "ATTENTION: La connexion réseau peut être interrompue momentanément"
    
    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
}

configure_netplan() {
    log "Configuration via Netplan..."
    
    # Sauvegarde de la configuration actuelle
    if [ -f /etc/netplan/01-netcfg.yaml ]; then
        cp /etc/netplan/01-netcfg.yaml /etc/netplan/01-netcfg.yaml.backup.$(date +%Y%m%d_%H%M%S)
    fi
    
    # Création du fichier Netplan
    cat > /etc/netplan/01-netcfg.yaml <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $NETWORK_INTERFACE:
      dhcp4: no
      addresses:
        - $STATIC_IP/$CIDR
      routes:
        - to: default
          via: $GATEWAY
      nameservers:
        addresses:
EOF
    
    echo "          - $DNS1" >> /etc/netplan/01-netcfg.yaml
    if [ -n "$DNS2" ]; then
        echo "          - $DNS2" >> /etc/netplan/01-netcfg.yaml
    fi
    
    # Tester la configuration
    netplan try --timeout 10 || error "Erreur lors de l'application de la configuration Netplan"
    netplan apply
    
    log "Configuration Netplan appliquée"
}

configure_interfaces() {
    log "Configuration via /etc/network/interfaces..."
    
    # Sauvegarde de la configuration actuelle
    cp /etc/network/interfaces /etc/network/interfaces.backup.$(date +%Y%m%d_%H%M%S)
    
    # Configuration de l'interface
    cat >> /etc/network/interfaces <<EOF

# Configuration statique pour $NETWORK_INTERFACE
auto $NETWORK_INTERFACE
iface $NETWORK_INTERFACE inet static
    address $STATIC_IP
    netmask $NETMASK
    gateway $GATEWAY
    dns-nameservers $DNS1${DNS2:+ $DNS2}
EOF
    
    # Configuration des DNS
    cat > /etc/resolv.conf <<EOF
nameserver $DNS1
EOF
    if [ -n "$DNS2" ]; then
        echo "nameserver $DNS2" >> /etc/resolv.conf
    fi
    
    # Redémarrage du service réseau
    systemctl restart networking || /etc/init.d/networking restart
    
    log "Configuration réseau appliquée"
}

################################################################################
# Configuration
################################################################################

setup_configuration() {
    log "Configuration de l'installation..."
    
    # Mot de passe pour l'utilisateur Zabbix de la base de données
    read -sp "Entrez le mot de passe pour l'utilisateur 'zabbix' de la base de données: " ZABBIX_DB_PASSWORD
    echo
    read -sp "Confirmez le mot de passe: " ZABBIX_DB_PASSWORD_CONFIRM
    echo
    
    if [ "$ZABBIX_DB_PASSWORD" != "$ZABBIX_DB_PASSWORD_CONFIRM" ]; then
        error "Les mots de passe ne correspondent pas"
    fi
    
    if [ -z "$ZABBIX_DB_PASSWORD" ]; then
        error "Le mot de passe ne peut pas être vide"
    fi
    
    info "Configuration enregistrée"
}

################################################################################
# Étape 1: Mise à jour du système
################################################################################

update_system() {
    log "Étape 1/9: Vérification et mise à jour complète du système..."
    
    info "Mise à jour de la liste des paquets..."
    apt update >> "$LOG_FILE" 2>&1 || error "Échec de la mise à jour du système"
    
    # Vérifier s'il y a des mises à jour disponibles
    UPDATES=$(apt list --upgradable 2>/dev/null | grep -c upgradable || echo "0")
    if [ "$UPDATES" -gt 1 ]; then
        log "Nombre de paquets à mettre à jour: $((UPDATES-1))"
    else
        log "Système déjà à jour"
    fi
    
    info "Application des mises à jour du système (cela peut prendre plusieurs minutes)..."
    DEBIAN_FRONTEND=noninteractive apt upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" >> "$LOG_FILE" 2>&1 || error "Échec de la mise à niveau du système"
    
    info "Mise à jour complète (dist-upgrade)..."
    DEBIAN_FRONTEND=noninteractive apt dist-upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" >> "$LOG_FILE" 2>&1 || warning "Dist-upgrade partiellement réussi"
    
    info "Nettoyage des paquets obsolètes..."
    apt autoremove -y >> "$LOG_FILE" 2>&1
    apt autoclean >> "$LOG_FILE" 2>&1
    
    log "Système mis à jour avec succès"
    
    # Vérifier si un redémarrage est nécessaire
    if [ -f /var/run/reboot-required ]; then
        warning "Un redémarrage du système est recommandé après l'installation"
        warning "Fichier /var/run/reboot-required détecté"
    fi
}

################################################################################
# Étape 2: Installation des prérequis (Apache, PHP, modules)
################################################################################

install_prerequisites() {
    log "Étape 2/8: Installation d'Apache, PHP et des modules requis..."
    
    DEBIAN_FRONTEND=noninteractive apt install -y \
        apache2 \
        php \
        php-curl \
        php-zip \
        php-gd \
        php-intl \
        php-pear \
        php-imagick \
        php-bz2 \
        php-imap \
        php-memcache \
        php-pspell \
        php-tidy \
        php-xmlrpc \
        php-xsl \
        php-mbstring \
        php-ldap \
        php-cas \
        php-apcu \
        libapache2-mod-php \
        php-mysql >> "$LOG_FILE" 2>&1 || error "Échec de l'installation des prérequis"
    
    log "Prérequis installés avec succès"
}

################################################################################
# Étape 3: Installation et sécurisation de MariaDB
################################################################################

install_mariadb() {
    log "Étape 3/8: Installation de MariaDB..."
    
    DEBIAN_FRONTEND=noninteractive apt install -y mariadb-server >> "$LOG_FILE" 2>&1 || error "Échec de l'installation de MariaDB"
    
    # Démarrage de MariaDB
    systemctl start mariadb
    systemctl enable mariadb >> "$LOG_FILE" 2>&1
    
    log "MariaDB installé avec succès"
}

secure_mariadb() {
    log "Étape 4/8: Sécurisation de MariaDB..."
    
    # Configuration automatique de la sécurité MariaDB
    mysql -u root <<-EOF >> "$LOG_FILE" 2>&1
		UPDATE mysql.user SET plugin='unix_socket' WHERE User='root';
		DELETE FROM mysql.user WHERE User='';
		DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
		DROP DATABASE IF EXISTS test;
		DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
		FLUSH PRIVILEGES;
	EOF
    
    if [ $? -eq 0 ]; then
        log "MariaDB sécurisé avec succès"
    else
        warning "Certaines étapes de sécurisation ont échoué, vérifiez le log"
    fi
}

################################################################################
# Étape 5: Création de la base de données Zabbix
################################################################################

create_zabbix_database() {
    log "Étape 5/8: Création de la base de données Zabbix..."
    
    mysql -u root <<-EOF >> "$LOG_FILE" 2>&1
		CREATE DATABASE IF NOT EXISTS zabbix character set utf8mb4 collate utf8mb4_bin;
		CREATE USER IF NOT EXISTS 'zabbix'@'localhost' IDENTIFIED BY '$ZABBIX_DB_PASSWORD';
		GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
		SET GLOBAL log_bin_trust_function_creators = 1;
		FLUSH PRIVILEGES;
	EOF
    
    if [ $? -eq 0 ]; then
        log "Base de données Zabbix créée avec succès"
    else
        error "Échec de la création de la base de données Zabbix"
    fi
}

################################################################################
# Étape 6: Installation de Zabbix 7.4
################################################################################

install_zabbix() {
    log "Étape 6/8: Installation de Zabbix 7.4..."
    
    # Téléchargement du paquet de release Zabbix
    cd /tmp
    wget -q https://repo.zabbix.com/zabbix/7.4/release/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.4+debian13_all.deb \
        || error "Échec du téléchargement du paquet Zabbix release"
    
    # Installation du paquet de release
    dpkg -i zabbix-release_latest_7.4+debian13_all.deb >> "$LOG_FILE" 2>&1
    
    # Mise à jour des dépôts
    apt update >> "$LOG_FILE" 2>&1 || error "Échec de la mise à jour des dépôts Zabbix"
    
    # Installation des composants Zabbix
    DEBIAN_FRONTEND=noninteractive apt install -y \
        zabbix-server-mysql \
        zabbix-frontend-php \
        zabbix-apache-conf \
        zabbix-sql-scripts \
        zabbix-agent >> "$LOG_FILE" 2>&1 || error "Échec de l'installation de Zabbix"
    
    log "Zabbix 7.4 installé avec succès"
}

################################################################################
# Étape 7: Importation des tables Zabbix et configuration
################################################################################

import_zabbix_schema() {
    log "Étape 7/8: Importation du schéma de base de données Zabbix..."
    
    zcat /usr/share/zabbix/sql-scripts/mysql/server.sql.gz | \
        mysql --default-character-set=utf8mb4 -uzabbix -p"$ZABBIX_DB_PASSWORD" zabbix \
        >> "$LOG_FILE" 2>&1 || error "Échec de l'importation du schéma Zabbix"
    
    # Désactivation de log_bin_trust_function_creators
    mysql -u root <<-EOF >> "$LOG_FILE" 2>&1
		SET GLOBAL log_bin_trust_function_creators = 0;
	EOF
    
    log "Schéma de base de données importé avec succès"
}

configure_zabbix_server() {
    log "Configuration du serveur Zabbix..."
    
    # Sauvegarde du fichier de configuration original
    cp /etc/zabbix/zabbix_server.conf /etc/zabbix/zabbix_server.conf.backup
    
    # Configuration du mot de passe de la base de données
    sed -i "s/^# DBPassword=.*/DBPassword=$ZABBIX_DB_PASSWORD/" /etc/zabbix/zabbix_server.conf
    sed -i "s/^DBPassword=.*/DBPassword=$ZABBIX_DB_PASSWORD/" /etc/zabbix/zabbix_server.conf
    
    log "Serveur Zabbix configuré avec succès"
}

################################################################################
# Étape 8: Démarrage des services
################################################################################

start_services() {
    log "Étape 8/8: Démarrage et activation des services..."
    
    # Redémarrage des services
    systemctl restart zabbix-server zabbix-agent apache2 >> "$LOG_FILE" 2>&1 || error "Échec du redémarrage des services"
    
    # Activation au démarrage
    systemctl enable zabbix-server zabbix-agent apache2 >> "$LOG_FILE" 2>&1 || error "Échec de l'activation des services"
    
    log "Services démarrés et activés avec succès"
}

################################################################################
# Vérification de l'installation
################################################################################

verify_installation() {
    log "Vérification de l'installation..."
    
    # Vérification du statut des services
    if systemctl is-active --quiet zabbix-server; then
        log "✓ Zabbix Server: actif"
    else
        warning "✗ Zabbix Server: inactif"
    fi
    
    if systemctl is-active --quiet zabbix-agent; then
        log "✓ Zabbix Agent: actif"
    else
        warning "✗ Zabbix Agent: inactif"
    fi
    
    if systemctl is-active --quiet apache2; then
        log "✓ Apache2: actif"
    else
        warning "✗ Apache2: inactif"
    fi
    
    if systemctl is-active --quiet mariadb; then
        log "✓ MariaDB: actif"
    else
        warning "✗ MariaDB: inactif"
    fi
}

################################################################################
# Affichage des informations finales
################################################################################

display_final_info() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo -e "${GREEN}Installation de Zabbix 7.4 terminée avec succès !${NC}"
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo ""
    echo "Informations importantes:"
    echo "------------------------"
    echo -e "Interface web: ${BLUE}http://$(hostname -I | awk '{print $1}')/zabbix${NC}"
    echo -e "              ou ${BLUE}http://localhost/zabbix${NC}"
    echo ""
    echo "Identifiants par défaut:"
    echo "  Utilisateur: Admin"
    echo "  Mot de passe: zabbix"
    echo ""
    echo "Base de données:"
    echo "  Nom: zabbix"
    echo "  Utilisateur: zabbix"
    echo "  Mot de passe: [celui que vous avez configuré]"
    echo ""
    echo "Fichiers de configuration:"
    echo "  - Serveur Zabbix: /etc/zabbix/zabbix_server.conf"
    echo "  - Agent Zabbix: /etc/zabbix/zabbix_agentd.conf"
    echo "  - Apache: /etc/apache2/conf-enabled/zabbix.conf"
    echo ""
    echo "Fichier de log de l'installation: $LOG_FILE"
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo -e "${YELLOW}Note: N'oubliez pas de changer le mot de passe Admin par défaut !${NC}"
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo ""
}

################################################################################
# Fonction principale
################################################################################

main() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo "          Script d'installation automatisée de Zabbix 7.4 sur Debian"
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo ""
    
    # Vérifications préalables
    check_root
    check_debian
    
    # Configuration
    setup_configuration
    
    echo ""
    log "Début de l'installation..."
    echo ""
    
    # Exécution des étapes d'installation
    update_system
    install_prerequisites
    install_mariadb
    secure_mariadb
    create_zabbix_database
    install_zabbix
    import_zabbix_schema
    configure_zabbix_server
    start_services
    
    # Vérification et affichage des informations
    verify_installation
    display_final_info
    
    log "Installation terminée !"
}

################################################################################
# Exécution du script
################################################################################

# Création du fichier de log
touch "$LOG_FILE" 2>/dev/null || LOG_FILE="./zabbix_installation.log"

# Lancement de l'installation
main

exit 0
