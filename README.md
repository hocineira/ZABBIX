# Script d'Installation Automatisée de Zabbix 7.4 sur Debian

![Zabbix](https://img.shields.io/badge/Zabbix-7.4-red?style=flat-square)
![Debian](https://img.shields.io/badge/Debian-13-blue?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)

Script d'installation automatisée et complète de **Zabbix 7.4** sur systèmes Debian. Ce script simplifie l'installation de Zabbix en automatisant toutes les étapes nécessaires, de la configuration du système à la mise en place de la base de données et des services.

## 📋 Table des matières

- [Fonctionnalités](#-fonctionnalités)
- [Prérequis](#-prérequis)
- [Installation](#-installation)
- [Utilisation](#-utilisation)
- [Ce que fait le script](#-ce-que-fait-le-script)
- [Post-installation](#-post-installation)
- [Dépannage](#-dépannage)
- [Sécurité](#-sécurité)
- [Logs](#-logs)
- [Désinstallation](#-désinstallation)
- [Contribution](#-contribution)
- [Licence](#-licence)

## ✨ Fonctionnalités

- ✅ **Configuration réseau automatique** (IP statique, passerelle, DNS)
- ✅ Installation complète et automatisée de Zabbix 7.4
- ✅ **Mise à jour complète du système** avec vérification détaillée
- ✅ Configuration de MariaDB avec sécurisation automatique
- ✅ Installation et configuration d'Apache2 et PHP avec tous les modules requis
- ✅ Création et configuration de la base de données Zabbix
- ✅ Configuration automatique du serveur Zabbix
- ✅ Activation automatique des services au démarrage
- ✅ Vérification de l'installation
- ✅ Gestion des erreurs avec logs détaillés
- ✅ Affichage coloré et informatif
- ✅ Sauvegarde automatique des fichiers de configuration

## 🔧 Prérequis

- **Système d'exploitation**: Debian 13 (ou version compatible)
- **Privilèges**: Accès root ou sudo
- **Connexion Internet**: Requise pour télécharger les paquets
- **Espace disque**: Au moins 2 GB d'espace libre
- **Mémoire RAM**: Minimum 1 GB (2 GB recommandé)

## 📥 Installation

### Méthode 1: Clonage depuis GitHub

```bash
# Cloner le dépôt
git clone https://github.com/votre-username/zabbix-auto-install.git

# Accéder au répertoire
cd zabbix-auto-install

# Rendre le script exécutable
chmod +x install_zabbix.sh
```

### Méthode 2: Téléchargement direct

```bash
# Télécharger le script
wget https://raw.githubusercontent.com/votre-username/zabbix-auto-install/main/install_zabbix.sh

# Rendre le script exécutable
chmod +x install_zabbix.sh
```

### Méthode 3: Installation en une ligne

```bash
curl -fsSL https://raw.githubusercontent.com/votre-username/zabbix-auto-install/main/install_zabbix.sh | sudo bash
```

## 🚀 Utilisation

### Exécution du script

```bash
sudo ./install_zabbix.sh
```

Le script vous guidera à travers plusieurs étapes de configuration :

#### 1. Configuration réseau (optionnelle)
- **Choix de l'interface réseau** (si plusieurs interfaces disponibles)
- **Affichage de la configuration actuelle** (IP, passerelle, DNS)
- **Option de configuration IP statique** :
  - Adresse IP statique (ex: 192.168.1.100)
  - Masque de sous-réseau (ex: 255.255.255.0 ou 24)
  - Passerelle (ex: 192.168.1.1)
  - DNS primaire (ex: 8.8.8.8)
  - DNS secondaire [optionnel] (ex: 8.8.4.4)

> 💡 **Note**: La configuration réseau est recommandée pour les serveurs de production qui nécessitent une IP statique.

#### 2. Configuration de la base de données
- **Mot de passe pour la base de données Zabbix**: Entrez un mot de passe fort et sécurisé
- **Confirmation du mot de passe**: Confirmez le mot de passe

Ensuite, le script s'occupe de tout automatiquement !

### Exemple d'exécution

```bash
$ sudo ./install_zabbix.sh

═══════════════════════════════════════════════════════════════════════════════
          Script d'installation automatisée de Zabbix 7.4 sur Debian
═══════════════════════════════════════════════════════════════════════════════

[2025-01-XX XX:XX:XX] Système Debian détecté: 13

Configuration réseau actuelle:
    inet 192.168.1.50/24 brd 192.168.1.255 scope global eth0
Passerelle actuelle:
default via 192.168.1.1 dev eth0
DNS actuels:
nameserver 192.168.1.1

Voulez-vous configurer une IP statique? (o/N): o
Adresse IP statique (ex: 192.168.1.100): 192.168.1.100
Masque de sous-réseau (ex: 255.255.255.0 ou 24): 24
Passerelle (ex: 192.168.1.1): 192.168.1.1
DNS primaire (ex: 8.8.8.8): 8.8.8.8
DNS secondaire (ex: 8.8.4.4) [optionnel]: 8.8.4.4

Entrez le mot de passe pour l'utilisateur 'zabbix' de la base de données: 
Confirmez le mot de passe: 

[2025-01-XX XX:XX:XX] Début de l'installation...
[2025-01-XX XX:XX:XX] Étape 1/9: Vérification et mise à jour complète du système...
[2025-01-XX XX:XX:XX] Nombre de paquets à mettre à jour: 42
[2025-01-XX XX:XX:XX] Système mis à jour avec succès
...
```

## 🔍 Ce que fait le script

Le script effectue les opérations suivantes de manière automatique:

### 0. Configuration réseau (optionnelle)
- Détection automatique des interfaces réseau disponibles
- Affichage de la configuration réseau actuelle
- Configuration d'une IP statique avec :
  - Support de Netplan (Debian 12+) et /etc/network/interfaces (Debian 11-)
  - Configuration de l'adresse IP et du masque de sous-réseau
  - Configuration de la passerelle par défaut
  - Configuration des serveurs DNS (primaire et secondaire)
  - Sauvegarde automatique de la configuration précédente
  - Application immédiate de la nouvelle configuration

### 1. Vérifications préalables
- Vérification des privilèges root
- Vérification du système Debian
- Configuration du mot de passe de la base de données

### 2. Mise à jour complète du système
```bash
apt update && apt upgrade -y && apt dist-upgrade -y
```
- Mise à jour de la liste des paquets
- Comptage et affichage du nombre de paquets à mettre à jour
- Application de toutes les mises à jour disponibles
- Mise à jour de distribution (dist-upgrade)
- Nettoyage des paquets obsolètes
- Détection si un redémarrage est nécessaire

### 3. Installation des prérequis
- Apache2 (serveur web)
- PHP 8.x et modules nécessaires:
  - php-curl, php-zip, php-gd, php-intl
  - php-mbstring, php-ldap, php-mysql
  - php-memcache, php-pspell, php-tidy
  - php-xmlrpc, php-xsl, php-cas, php-apcu
  - libapache2-mod-php
- ipcalc (pour les calculs réseau)

### 4. Installation et sécurisation de MariaDB
- Installation de MariaDB Server
- Configuration automatique de la sécurité:
  - Activation de l'authentification unix_socket pour root
  - Suppression des utilisateurs anonymes
  - Désactivation de la connexion root distante
  - Suppression de la base de données test

### 5. Création de la base de données Zabbix
- Création de la base `zabbix` avec encodage UTF8MB4
- Création de l'utilisateur `zabbix@localhost`
- Attribution des privilèges nécessaires

### 6. Installation de Zabbix 7.4
- Ajout du dépôt officiel Zabbix
- Installation de:
  - `zabbix-server-mysql` (serveur Zabbix)
  - `zabbix-frontend-php` (interface web)
  - `zabbix-apache-conf` (configuration Apache)
  - `zabbix-sql-scripts` (scripts SQL)
  - `zabbix-agent` (agent de surveillance)

### 7. Configuration de Zabbix
- Importation du schéma de base de données
- Configuration du fichier `/etc/zabbix/zabbix_server.conf`
- Sauvegarde de la configuration originale

### 8. Démarrage des services
- Démarrage et activation de:
  - `zabbix-server`
  - `zabbix-agent`
  - `apache2`
  - `mariadb`

### 9. Vérification de l'installation
- Vérification du statut de tous les services
- Affichage des informations de connexion

## 📱 Post-installation

### Accès à l'interface web

Une fois l'installation terminée, accédez à l'interface web de Zabbix:

```
http://VOTRE_IP_SERVER/zabbix
```

Ou en local:

```
http://localhost/zabbix
```

### Identifiants par défaut

- **Utilisateur**: `Admin`
- **Mot de passe**: `zabbix`

⚠️ **IMPORTANT**: Changez immédiatement le mot de passe par défaut après la première connexion!

### Configuration de l'interface web

Lors de la première connexion, l'assistant de configuration vous guidera:

1. **Bienvenue**: Cliquez sur "Next step"
2. **Prérequis**: Vérifiez que tous les prérequis sont OK
3. **Configuration de la base de données**:
   - Type: MySQL
   - Hôte: localhost
   - Port: 3306 (par défaut)
   - Nom de la base: zabbix
   - Utilisateur: zabbix
   - Mot de passe: [le mot de passe que vous avez configuré]
4. **Configuration du serveur**: Laissez les valeurs par défaut
5. **Configuration finale**: Vérifiez et confirmez
6. **Connexion**: Utilisez les identifiants par défaut

### Recommandations de sécurité post-installation

1. **Changer le mot de passe Admin**:
   ```
   Administration → Users → Admin → Password
   ```

2. **Configurer le firewall** (si nécessaire):
   ```bash
   # UFW
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw allow 10050/tcp  # Zabbix agent
   sudo ufw allow 10051/tcp  # Zabbix server
   ```

3. **Configurer HTTPS** (recommandé pour la production):
   ```bash
   sudo apt install certbot python3-certbot-apache
   sudo certbot --apache
   ```

4. **Créer des utilisateurs supplémentaires** avec des privilèges appropriés

## 🐛 Dépannage

### Problèmes courants

#### 0. Problème de réseau après configuration

```bash
# Vérifier la configuration réseau
ip addr show
ip route show
cat /etc/resolv.conf

# Pour Netplan
sudo netplan status
sudo netplan apply

# Pour interfaces
sudo systemctl restart networking

# Restaurer la configuration précédente (si nécessaire)
# Pour Netplan
sudo cp /etc/netplan/01-netcfg.yaml.backup.YYYYMMDD_HHMMSS /etc/netplan/01-netcfg.yaml
sudo netplan apply

# Pour interfaces
sudo cp /etc/network/interfaces.backup.YYYYMMDD_HHMMSS /etc/network/interfaces
sudo systemctl restart networking
```

#### 1. Le serveur Zabbix ne démarre pas

```bash
# Vérifier les logs
sudo tail -f /var/log/zabbix/zabbix_server.log

# Vérifier la configuration
sudo zabbix_server -c /etc/zabbix/zabbix_server.conf -t

# Redémarrer le service
sudo systemctl restart zabbix-server
```

#### 2. Impossible d'accéder à l'interface web

```bash
# Vérifier qu'Apache est actif
sudo systemctl status apache2

# Redémarrer Apache
sudo systemctl restart apache2

# Vérifier la configuration Apache de Zabbix
cat /etc/apache2/conf-enabled/zabbix.conf
```

#### 3. Erreur de connexion à la base de données

```bash
# Tester la connexion
mysql -uzabbix -p zabbix

# Vérifier le mot de passe dans la configuration
sudo grep "DBPassword" /etc/zabbix/zabbix_server.conf

# Si nécessaire, réinitialiser le mot de passe
sudo mysql -u root
ALTER USER 'zabbix'@'localhost' IDENTIFIED BY 'nouveau_mot_de_passe';
FLUSH PRIVILEGES;
EXIT;

# Mettre à jour le fichier de configuration
sudo nano /etc/zabbix/zabbix_server.conf
```

#### 4. Consulter les logs d'installation

```bash
# Log complet de l'installation
sudo cat /var/log/zabbix_installation.log

# Dernières lignes du log
sudo tail -n 50 /var/log/zabbix_installation.log
```

### Vérification des services

```bash
# Statut de tous les services Zabbix
sudo systemctl status zabbix-server zabbix-agent apache2 mariadb

# Redémarrer tous les services
sudo systemctl restart zabbix-server zabbix-agent apache2
```

## 🔒 Sécurité

### Bonnes pratiques

1. **Mots de passe forts**: Utilisez des mots de passe complexes
2. **Mises à jour régulières**: Maintenez votre système à jour
   ```bash
   sudo apt update && sudo apt upgrade
   ```
3. **Firewall**: Configurez un firewall pour limiter l'accès
4. **HTTPS**: Utilisez SSL/TLS pour sécuriser l'interface web
5. **Surveillance**: Surveillez les logs régulièrement
6. **Sauvegardes**: Effectuez des sauvegardes régulières de la base de données
   ```bash
   mysqldump -uzabbix -p zabbix > zabbix_backup_$(date +%Y%m%d).sql
   ```

### Durcissement de la sécurité

```bash
# Désactiver l'utilisateur guest dans Zabbix (via l'interface web)
# Administration → Users → guest → Disabled

# Limiter l'accès SSH (optionnel)
sudo nano /etc/ssh/sshd_config
# Définir: PermitRootLogin no

# Configurer fail2ban (optionnel)
sudo apt install fail2ban
```

## 📝 Logs

Les fichiers de logs importants:

- **Installation**: `/var/log/zabbix_installation.log`
- **Serveur Zabbix**: `/var/log/zabbix/zabbix_server.log`
- **Agent Zabbix**: `/var/log/zabbix/zabbix_agentd.log`
- **Apache**: `/var/log/apache2/error.log`
- **MariaDB**: `/var/log/mysql/error.log`

## 🗑️ Désinstallation

Pour désinstaller Zabbix complètement:

```bash
# Arrêter les services
sudo systemctl stop zabbix-server zabbix-agent

# Désinstaller les paquets Zabbix
sudo apt remove --purge zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

# Supprimer la base de données (ATTENTION: suppression définitive!)
sudo mysql -u root -p
DROP DATABASE zabbix;
DROP USER 'zabbix'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# Supprimer les fichiers de configuration
sudo rm -rf /etc/zabbix
sudo rm -rf /var/log/zabbix

# Nettoyer les dépendances
sudo apt autoremove
```

## 📂 Structure du projet

```
zabbix-auto-install/
├── install_zabbix.sh      # Script principal d'installation
├── README.md              # Documentation (ce fichier)
├── LICENSE                # Licence du projet
└── .gitignore             # Fichiers à ignorer par Git
```

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer:

1. Forkez le projet
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Poussez vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

### Rapporter des bugs

Pour rapporter un bug, ouvrez une issue en incluant:
- Description détaillée du problème
- Étapes pour reproduire
- Système d'exploitation et version
- Logs pertinents

## 📜 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 📞 Support

Si vous rencontrez des problèmes:
- 🐛 Ouvrez une [issue sur GitHub](https://github.com/votre-username/zabbix-auto-install/issues)
- 📧 Contactez-moi par email
- 💬 Rejoignez notre communauté

## 🙏 Remerciements

- [Zabbix](https://www.zabbix.com/) pour leur excellent logiciel de monitoring
- La communauté Debian
- Tous les contributeurs du projet

## 📊 Versions supportées

| Version Zabbix | Version Debian | Status |
|----------------|----------------|--------|
| 7.4            | 13             | ✅ Supporté |
| 7.4            | 12             | ⚠️ Non testé |
| 7.x            | 11             | ⚠️ Non testé |

---

**Note**: Ce script est fourni "tel quel" sans garantie. Testez toujours dans un environnement de développement avant de l'utiliser en production.

**Développé avec ❤️ pour la communauté Zabbix**
