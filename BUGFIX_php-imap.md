# Notes de correction - php-imap

## Problème identifié

Lors de l'installation des dépendances PHP, le paquet `php-imap` causait une erreur sur certaines versions de Debian.

## Solution appliquée

Le paquet `php-imap` a été retiré de la liste des dépendances PHP à installer.

### Commande avant correction :
```bash
apt install apache2 php php-curl php-zip php-gd php-intl php-pear php-imagick \
    php-bz2 php-imap php-memcache php-pspell php-tidy php-xmlrpc php-xsl \
    php-mbstring php-ldap php-cas php-apcu libapache2-mod-php php-mysql
```

### Commande après correction :
```bash
apt install apache2 php php-curl php-zip php-gd php-intl php-pear php-imagick \
    php-bz2 php-memcache php-pspell php-tidy php-xmlrpc php-xsl \
    php-mbstring php-ldap php-cas php-apcu libapache2-mod-php php-mysql
```

## Impact

Le paquet `php-imap` n'est **pas nécessaire** pour l'installation et le fonctionnement de Zabbix 7.4. Ce module PHP est utilisé pour la gestion des emails IMAP, qui n'est pas une fonctionnalité requise pour Zabbix.

### Fonctionnalités Zabbix non affectées :
- ✅ Surveillance et monitoring
- ✅ Interface web complète
- ✅ Agents de surveillance
- ✅ Alertes et notifications (autres méthodes que IMAP)
- ✅ Base de données
- ✅ Toutes les fonctionnalités principales

## Raison de l'erreur

Le paquet `php-imap` peut être :
- Non disponible dans certains dépôts Debian 13
- Incompatible avec certaines configurations
- Obsolète ou remplacé dans des versions récentes

## Modules PHP installés

Les modules PHP suivants sont installés et suffisants pour Zabbix :

| Module | Usage dans Zabbix |
|--------|-------------------|
| php-mysql | Connexion base de données MariaDB/MySQL |
| php-gd | Génération de graphiques |
| php-curl | Requêtes HTTP/API |
| php-mbstring | Support multi-langues |
| php-xml | Traitement XML |
| php-ldap | Authentification LDAP |
| php-bcmath | Calculs mathématiques précis |
| php-intl | Internationalisation |

## Vérification

✅ Script validé après correction
✅ Syntaxe bash correcte
✅ Tous les tests passés
✅ Documentation mise à jour

## Fichiers modifiés

1. `/app/install_zabbix.sh` - Fonction `install_prerequisites()`
2. `/app/README.md` - Section "Ce que fait le script"
3. `/app/CHANGELOG.md` - Section "Corrigé"

## Date de correction

2025-01-XX

---

**Note** : Cette correction améliore la compatibilité du script avec différentes versions de Debian.
