# Changelog

Tous les changements notables de ce projet seront documentés dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

## [1.0.0] - 2025-01-XX

### Ajouté
- Script d'installation automatisée initial pour Zabbix 7.4 sur Debian
- **Configuration réseau avec IP statique, passerelle et DNS**
- **Mise à jour complète du système avec vérification détaillée (apt update, upgrade, dist-upgrade)**
- Installation automatique de MariaDB avec configuration de sécurité
- Installation automatique d'Apache2 et PHP avec tous les modules requis
- Création automatique de la base de données Zabbix
- Configuration automatique du serveur Zabbix
- Gestion complète des erreurs avec logging détaillé
- Vérification de l'installation et statut des services
- Interface colorée et informative
- Documentation complète en français
- Fichier README.md détaillé
- Licence MIT
- Fichier .gitignore

### Fonctionnalités réseau
- **Détection automatique des interfaces réseau**
- **Support Netplan (Debian 12+) et /etc/network/interfaces (Debian 11-)**
- **Configuration IP statique avec masque de sous-réseau**
- **Configuration de la passerelle par défaut**
- **Configuration DNS (primaire et secondaire)**
- **Sauvegarde automatique de la configuration réseau précédente**

### Corrigé
- **Retrait de php-imap** de la liste des dépendances (paquet problématique sur certaines versions de Debian)

### Sécurité
- Sécurisation automatique de MariaDB
- Demande de mot de passe sécurisé pour la base de données
- Sauvegarde automatique des fichiers de configuration

---

## [À venir]

### Prévu pour la version 1.1.0
- Support pour d'autres distributions Linux (Ubuntu, CentOS)
- Option de configuration avancée en ligne de commande
- Script de désinstallation automatique
- Configuration automatique de HTTPS avec Let's Encrypt
- Support pour l'installation de Zabbix Proxy
- Mode silencieux (installation non interactive)

### Prévu pour la version 1.2.0
- Importation automatique de templates
- Configuration de notifications (email, Slack, etc.)
- Script de sauvegarde automatique
- Script de mise à jour de Zabbix

---

## Types de changements

- `Ajouté` pour les nouvelles fonctionnalités
- `Modifié` pour les changements dans les fonctionnalités existantes
- `Obsolète` pour les fonctionnalités qui seront bientôt supprimées
- `Supprimé` pour les fonctionnalités supprimées
- `Corrigé` pour les corrections de bugs
- `Sécurité` pour les vulnérabilités corrigées
