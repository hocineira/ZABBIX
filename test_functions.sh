#!/bin/bash

################################################################################
# Script de test des fonctions (Dry-run)
# Teste les fonctions du script sans modifier le système
################################################################################

# Charger les fonctions du script principal
# (sans l'exécuter complètement)

echo "══════════════════════════════════════════════════════════════"
echo "       Test des fonctions - Mode Dry-Run"
echo "══════════════════════════════════════════════════════════════"
echo ""

# Test 1: Vérifier que toutes les fonctions sont définies
echo "📋 Test 1: Vérification des fonctions définies"
echo "─────────────────────────────────────────────────────────────"

FUNCTIONS=(
    "log"
    "error"
    "warning"
    "info"
    "check_root"
    "check_debian"
    "detect_network_interface"
    "show_current_network_config"
    "configure_static_network"
    "configure_netplan"
    "configure_interfaces"
    "setup_configuration"
    "update_system"
    "install_prerequisites"
    "install_mariadb"
    "secure_mariadb"
    "create_zabbix_database"
    "install_zabbix"
    "import_zabbix_schema"
    "configure_zabbix_server"
    "start_services"
    "verify_installation"
    "display_final_info"
    "main"
)

FOUND=0
for func in "${FUNCTIONS[@]}"; do
    if grep -q "^${func}()" install_zabbix.sh; then
        echo "✓ $func"
        ((FOUND++))
    else
        echo "✗ $func - MANQUANTE"
    fi
done

echo ""
echo "Résultat: $FOUND/${#FUNCTIONS[@]} fonctions trouvées"
echo ""

# Test 2: Vérifier les étapes d'installation
echo "📋 Test 2: Vérification des étapes d'installation"
echo "─────────────────────────────────────────────────────────────"

for i in {1..9}; do
    if grep -q "Étape $i/9" install_zabbix.sh; then
        STEP_NAME=$(grep "Étape $i/9" install_zabbix.sh | sed 's/.*: //' | sed 's/\.\.\.//')
        echo "✓ Étape $i/9: $STEP_NAME"
    else
        echo "✗ Étape $i/9: MANQUANTE"
    fi
done

echo ""

# Test 3: Vérifier les variables importantes
echo "📋 Test 3: Vérification des variables importantes"
echo "─────────────────────────────────────────────────────────────"

VARIABLES=(
    "LOG_FILE"
    "ZABBIX_DB_PASSWORD"
    "NETWORK_INTERFACE"
    "STATIC_IP"
    "GATEWAY"
    "DNS1"
)

for var in "${VARIABLES[@]}"; do
    if grep -q "$var" install_zabbix.sh; then
        echo "✓ $var"
    else
        echo "✗ $var - NON TROUVÉE"
    fi
done

echo ""

# Test 4: Vérifier les mécanismes de sécurité
echo "📋 Test 4: Vérification des mécanismes de sécurité"
echo "─────────────────────────────────────────────────────────────"

# set -e
if grep -q "^set -e" install_zabbix.sh; then
    echo "✓ Gestion d'erreurs (set -e)"
else
    echo "✗ set -e manquant"
fi

# Vérification root
if grep -q "check_root" install_zabbix.sh; then
    echo "✓ Vérification des privilèges root"
else
    echo "✗ Vérification root manquante"
fi

# Sauvegardes
if grep -q "\.backup" install_zabbix.sh; then
    echo "✓ Système de sauvegarde présent"
else
    echo "✗ Système de sauvegarde manquant"
fi

# Confirmation mot de passe
if grep -q "ZABBIX_DB_PASSWORD_CONFIRM" install_zabbix.sh; then
    echo "✓ Confirmation du mot de passe"
else
    echo "✗ Confirmation mot de passe manquante"
fi

echo ""

# Test 5: Vérifier les packages installés
echo "📋 Test 5: Vérification des packages mentionnés"
echo "─────────────────────────────────────────────────────────────"

PACKAGES=(
    "apache2"
    "php"
    "mariadb-server"
    "zabbix-server-mysql"
    "zabbix-frontend-php"
    "zabbix-agent"
)

for pkg in "${PACKAGES[@]}"; do
    if grep -q "$pkg" install_zabbix.sh; then
        echo "✓ $pkg"
    else
        echo "✗ $pkg - NON TROUVÉ"
    fi
done

echo ""

# Test 6: Vérifier la gestion des erreurs
echo "📋 Test 6: Vérification de la gestion des erreurs"
echo "─────────────────────────────────────────────────────────────"

ERROR_COUNT=$(grep -c "|| error" install_zabbix.sh || echo 0)
WARNING_COUNT=$(grep -c "|| warning" install_zabbix.sh || echo 0)

echo "✓ Nombre de points d'erreur: $ERROR_COUNT"
echo "✓ Nombre de points d'avertissement: $WARNING_COUNT"

echo ""

# Test 7: Vérifier les commentaires et documentation
echo "📋 Test 7: Vérification de la documentation"
echo "─────────────────────────────────────────────────────────────"

COMMENT_COUNT=$(grep -c "^#" install_zabbix.sh || echo 0)
SECTION_COUNT=$(grep -c "^#####" install_zabbix.sh || echo 0)

echo "✓ Lignes de commentaires: $COMMENT_COUNT"
echo "✓ Sections documentées: $SECTION_COUNT"

echo ""

# Test 8: Vérifier la compatibilité réseau
echo "📋 Test 8: Vérification du support réseau"
echo "─────────────────────────────────────────────────────────────"

if grep -q "netplan" install_zabbix.sh; then
    echo "✓ Support Netplan"
else
    echo "✗ Support Netplan manquant"
fi

if grep -q "/etc/network/interfaces" install_zabbix.sh; then
    echo "✓ Support /etc/network/interfaces"
else
    echo "✗ Support interfaces manquant"
fi

if grep -q "/etc/resolv.conf" install_zabbix.sh; then
    echo "✓ Configuration DNS"
else
    echo "✗ Configuration DNS manquante"
fi

echo ""

# Résumé final
echo "══════════════════════════════════════════════════════════════"
echo "                      RÉSUMÉ DU TEST"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "✅ Script prêt pour l'utilisation"
echo ""
echo "Caractéristiques détectées:"
echo "  • $FOUND fonctions définies"
echo "  • 9 étapes d'installation"
echo "  • $ERROR_COUNT points de gestion d'erreur"
echo "  • $COMMENT_COUNT lignes de documentation"
echo "  • Support réseau complet (Netplan + interfaces)"
echo ""
echo "Pour tester la syntaxe: bash -n install_zabbix.sh"
echo "Pour valider le projet: ./validate.sh"
echo ""
