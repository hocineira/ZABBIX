# Configuration Réseau - Guide Avancé

Ce document fournit des informations détaillées sur la configuration réseau effectuée par le script d'installation Zabbix.

## 📡 Vue d'ensemble

Le script d'installation offre la possibilité de configurer une adresse IP statique avant l'installation de Zabbix. Cette fonctionnalité est particulièrement importante pour les serveurs de production qui nécessitent une configuration réseau stable et prédictible.

## 🔧 Systèmes de configuration supportés

Le script détecte automatiquement le système de configuration réseau utilisé par votre distribution Debian :

### 1. Netplan (Debian 12 et versions ultérieures)

Netplan est le système de configuration réseau moderne utilisé par les versions récentes de Debian.

**Fichier de configuration** : `/etc/netplan/01-netcfg.yaml`

**Exemple de configuration générée** :
```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

**Commandes utiles** :
```bash
# Afficher la configuration actuelle
sudo netplan status

# Tester la configuration (timeout de 10 secondes)
sudo netplan try --timeout 10

# Appliquer la configuration
sudo netplan apply

# Voir les logs de debug
sudo netplan --debug apply
```

### 2. /etc/network/interfaces (Debian 11 et versions antérieures)

Système de configuration réseau traditionnel de Debian.

**Fichier de configuration** : `/etc/network/interfaces`

**Exemple de configuration générée** :
```
# Configuration statique pour eth0
auto eth0
iface eth0 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8 8.8.4.4
```

**Commandes utiles** :
```bash
# Redémarrer le service réseau
sudo systemctl restart networking

# Relancer une interface spécifique
sudo ifdown eth0 && sudo ifup eth0

# Vérifier la configuration
cat /etc/network/interfaces
```

## 🌐 Configuration DNS

Le script configure également les serveurs DNS de manière appropriée selon le système utilisé.

### Pour Netplan
Les DNS sont configurés dans le fichier YAML sous la section `nameservers`.

### Pour interfaces
Les DNS sont configurés dans `/etc/resolv.conf` :
```
nameserver 8.8.8.8
nameserver 8.8.4.4
```

## 📋 Informations demandées par le script

Lors de la configuration réseau, le script vous demandera :

| Paramètre | Description | Exemple | Obligatoire |
|-----------|-------------|---------|-------------|
| **Interface réseau** | L'interface à configurer | eth0, ens33 | Oui (auto-détecté) |
| **Adresse IP statique** | L'adresse IP fixe du serveur | 192.168.1.100 | Oui |
| **Masque de sous-réseau** | Masque réseau (format décimal ou CIDR) | 255.255.255.0 ou 24 | Oui |
| **Passerelle** | Adresse IP de la passerelle par défaut | 192.168.1.1 | Oui |
| **DNS primaire** | Serveur DNS principal | 8.8.8.8 | Oui |
| **DNS secondaire** | Serveur DNS de secours | 8.8.4.4 | Non |

## 💡 Recommandations

### Choix de l'adresse IP
- Utilisez une adresse dans la plage de votre réseau local
- Assurez-vous que l'adresse n'est pas déjà utilisée par un autre équipement
- Évitez les premières et dernières adresses de la plage (souvent réservées)

### Choix des DNS

#### DNS publics recommandés :

**Google DNS** (performant et fiable) :
- Primaire : 8.8.8.8
- Secondaire : 8.8.4.4

**Cloudflare DNS** (accent sur la confidentialité) :
- Primaire : 1.1.1.1
- Secondaire : 1.0.0.1

**Quad9 DNS** (bloque les domaines malveillants) :
- Primaire : 9.9.9.9
- Secondaire : 149.112.112.112

**OpenDNS** :
- Primaire : 208.67.222.222
- Secondaire : 208.67.220.220

#### DNS locaux :
Si vous avez un serveur DNS local (ex: Active Directory, Pi-hole), utilisez son adresse IP.

### Format du masque de sous-réseau

Le script accepte deux formats :

1. **Format décimal** : 255.255.255.0
2. **Format CIDR** : 24

Correspondances courantes :
| Décimal | CIDR | Nombre d'hôtes |
|---------|------|----------------|
| 255.255.255.0 | /24 | 254 |
| 255.255.254.0 | /23 | 510 |
| 255.255.252.0 | /22 | 1022 |
| 255.255.0.0 | /16 | 65534 |

## 🔍 Détection des interfaces réseau

Le script détecte automatiquement les interfaces réseau disponibles en excluant :
- L'interface loopback (lo)
- Les interfaces virtuelles

**Noms d'interface courants** :
- `eth0`, `eth1` : Ethernet (ancienne nomenclature)
- `ens33`, `ens160` : Ethernet (nouvelle nomenclature, machines virtuelles)
- `enp0s3`, `enp0s8` : Ethernet (nouvelle nomenclature, physique)
- `wlan0`, `wlp2s0` : Sans fil (WiFi)

Si plusieurs interfaces sont détectées, le script vous permettra de choisir celle à configurer.

## 💾 Sauvegardes automatiques

Le script crée automatiquement une sauvegarde de votre configuration réseau avant toute modification.

### Pour Netplan
Fichier de sauvegarde : `/etc/netplan/01-netcfg.yaml.backup.YYYYMMDD_HHMMSS`

### Pour interfaces
Fichier de sauvegarde : `/etc/network/interfaces.backup.YYYYMMDD_HHMMSS`

**Pour restaurer une sauvegarde** :
```bash
# Netplan
sudo cp /etc/netplan/01-netcfg.yaml.backup.YYYYMMDD_HHMMSS /etc/netplan/01-netcfg.yaml
sudo netplan apply

# Interfaces
sudo cp /etc/network/interfaces.backup.YYYYMMDD_HHMMSS /etc/network/interfaces
sudo systemctl restart networking
```

## 🐛 Dépannage

### La configuration réseau ne s'applique pas

1. **Vérifier la syntaxe du fichier de configuration**
   ```bash
   # Pour Netplan
   sudo netplan --debug apply
   
   # Pour interfaces
   sudo ifquery --list
   ```

2. **Vérifier que l'interface existe**
   ```bash
   ip link show
   ```

3. **Vérifier les logs système**
   ```bash
   sudo journalctl -u systemd-networkd
   sudo journalctl -u networking
   ```

### Perte de connexion après configuration

Si vous perdez la connexion SSH après la configuration réseau :

1. **Accès physique ou console** : Connectez-vous directement au serveur
2. **Restaurer la configuration** : Utilisez la sauvegarde créée automatiquement
3. **Vérifier la configuration** :
   ```bash
   ip addr show
   ip route show
   ping 8.8.8.8
   ```

### Impossible de résoudre les noms de domaine

1. **Vérifier les DNS configurés**
   ```bash
   cat /etc/resolv.conf
   ```

2. **Tester la résolution DNS**
   ```bash
   nslookup google.com
   # ou
   dig google.com
   ```

3. **Reconfigurer les DNS manuellement**
   ```bash
   sudo nano /etc/resolv.conf
   # Ajouter :
   # nameserver 8.8.8.8
   # nameserver 8.8.4.4
   ```

### Le service réseau ne redémarre pas

```bash
# Vérifier le statut
sudo systemctl status networking
sudo systemctl status systemd-networkd

# Voir les erreurs
sudo journalctl -xe

# Redémarrage forcé
sudo systemctl restart systemd-networkd
sudo systemctl restart networking
```

## 🔒 Sécurité réseau

Après avoir configuré votre réseau, considérez ces mesures de sécurité :

### 1. Configurer le pare-feu (UFW)
```bash
sudo apt install ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 10050/tcp  # Zabbix agent
sudo ufw allow 10051/tcp  # Zabbix server
sudo ufw enable
```

### 2. Limiter l'accès SSH
Éditez `/etc/ssh/sshd_config` :
```
PermitRootLogin no
PasswordAuthentication yes  # Changez en 'no' après avoir configuré les clés SSH
Port 22  # Considérez de changer le port par défaut
```

### 3. Configurer fail2ban
```bash
sudo apt install fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

## 📚 Ressources supplémentaires

- [Documentation Netplan](https://netplan.io/reference)
- [Debian Network Configuration](https://wiki.debian.org/NetworkConfiguration)
- [Zabbix Documentation](https://www.zabbix.com/documentation/current/manual)

## ✅ Vérification de la configuration

Après avoir configuré votre réseau, vérifiez que tout fonctionne :

```bash
# Vérifier l'adresse IP
ip addr show

# Vérifier la passerelle
ip route show

# Vérifier les DNS
cat /etc/resolv.conf

# Tester la connectivité Internet
ping -c 4 8.8.8.8

# Tester la résolution DNS
ping -c 4 google.com

# Vérifier les ports ouverts
sudo ss -tulpn
```

## 🆘 Support

Si vous rencontrez des problèmes avec la configuration réseau :
1. Consultez les logs d'installation : `/var/log/zabbix_installation.log`
2. Vérifiez les sauvegardes automatiques de configuration
3. Ouvrez une issue sur GitHub avec les détails de votre configuration

---

**Note** : Toujours tester la configuration réseau dans un environnement de test avant de l'appliquer en production.
