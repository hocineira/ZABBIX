#!/bin/bash

################################################################################
# Script de validation avant publication
# Vérifie que tous les fichiers sont corrects et prêts pour GitHub
################################################################################

set -e

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

success() {
    echo -e "${GREEN}✓${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

echo "══════════════════════════════════════════════════════════════"
echo "       Validation du projet Zabbix Auto Install"
echo "══════════════════════════════════════════════════════════════"
echo ""

ERRORS=0
WARNINGS=0

# 1. Vérifier la syntaxe du script principal
info "Vérification de la syntaxe du script..."
if bash -n install_zabbix.sh 2>/dev/null; then
    success "Syntaxe du script valide"
else
    error "Erreur de syntaxe dans install_zabbix.sh"
    ((ERRORS++))
fi

# 2. Vérifier que le script est exécutable
info "Vérification des permissions..."
if [ -x install_zabbix.sh ]; then
    success "Le script est exécutable"
else
    warning "Le script n'est pas exécutable (chmod +x install_zabbix.sh)"
    ((WARNINGS++))
fi

# 3. Vérifier la présence des fichiers essentiels
info "Vérification de la présence des fichiers..."
REQUIRED_FILES=(
    "install_zabbix.sh"
    "README.md"
    "LICENSE"
    "CHANGELOG.md"
    ".gitignore"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        success "Fichier présent: $file"
    else
        error "Fichier manquant: $file"
        ((ERRORS++))
    fi
done

# 4. Vérifier la présence de set -e
info "Vérification des bonnes pratiques..."
if grep -q "set -e" install_zabbix.sh; then
    success "Gestion d'erreurs activée (set -e)"
else
    warning "set -e non trouvé dans le script"
    ((WARNINGS++))
fi

# 5. Vérifier la présence de logging
if grep -q "LOG_FILE" install_zabbix.sh; then
    success "Système de logging présent"
else
    error "Système de logging manquant"
    ((ERRORS++))
fi

# 6. Vérifier la présence de fonctions
if grep -q "^[a-zA-Z_][a-zA-Z0-9_]*()" install_zabbix.sh; then
    success "Fonctions définies"
else
    error "Aucune fonction trouvée"
    ((ERRORS++))
fi

# 7. Vérifier la documentation
info "Vérification de la documentation..."
if grep -q "Configuration réseau" README.md; then
    success "Documentation de la configuration réseau présente"
else
    warning "Documentation de la configuration réseau manquante"
    ((WARNINGS++))
fi

if [ -f "NETWORK_CONFIG.md" ]; then
    success "Guide de configuration réseau présent"
else
    warning "NETWORK_CONFIG.md non trouvé"
    ((WARNINGS++))
fi

# 8. Vérifier le CHANGELOG
if [ -f "CHANGELOG.md" ]; then
    if grep -q "\[1.0.0\]" CHANGELOG.md; then
        success "Version 1.0.0 documentée dans CHANGELOG"
    else
        warning "Version non documentée dans CHANGELOG"
        ((WARNINGS++))
    fi
fi

# 9. Vérifier la structure du projet
info "Vérification de la structure..."
if [ -d ".github/workflows" ]; then
    success "Dossier GitHub Actions présent"
else
    warning "Pas de GitHub Actions configuré"
    ((WARNINGS++))
fi

# 10. Vérifier les caractéristiques du script
info "Analyse du contenu du script..."

# Vérifier les fonctions principales
MAIN_FUNCTIONS=(
    "configure_static_network"
    "update_system"
    "install_prerequisites"
    "install_mariadb"
    "create_zabbix_database"
    "install_zabbix"
)

for func in "${MAIN_FUNCTIONS[@]}"; do
    if grep -q "$func()" install_zabbix.sh; then
        success "Fonction présente: $func"
    else
        error "Fonction manquante: $func"
        ((ERRORS++))
    fi
done

# 11. Vérifier le README
info "Vérification du README..."
README_SECTIONS=(
    "Fonctionnalités"
    "Prérequis"
    "Installation"
    "Utilisation"
    "Post-installation"
    "Dépannage"
)

for section in "${README_SECTIONS[@]}"; do
    if grep -qi "$section" README.md; then
        success "Section présente: $section"
    else
        warning "Section manquante dans README: $section"
        ((WARNINGS++))
    fi
done

# 12. Statistiques du script
info "Statistiques du script..."
LINES=$(wc -l < install_zabbix.sh)
FUNCTIONS=$(grep -c "^[a-zA-Z_][a-zA-Z0-9_]*()" install_zabbix.sh || echo 0)
COMMENTS=$(grep -c "^#" install_zabbix.sh || echo 0)

echo "  Lignes de code: $LINES"
echo "  Fonctions: $FUNCTIONS"
echo "  Commentaires: $COMMENTS"

# 13. Taille des fichiers
info "Taille des fichiers..."
echo "  install_zabbix.sh: $(du -h install_zabbix.sh | cut -f1)"
echo "  README.md: $(du -h README.md | cut -f1)"

# Résumé
echo ""
echo "══════════════════════════════════════════════════════════════"
echo "                      RÉSUMÉ"
echo "══════════════════════════════════════════════════════════════"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ Tous les tests sont passés avec succès !${NC}"
    echo ""
    echo "Le projet est prêt à être publié sur GitHub."
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Tests passés avec $WARNINGS avertissement(s)${NC}"
    echo ""
    echo "Le projet peut être publié, mais certaines améliorations sont recommandées."
    exit 0
else
    echo -e "${RED}✗ Tests échoués: $ERRORS erreur(s), $WARNINGS avertissement(s)${NC}"
    echo ""
    echo "Corrigez les erreurs avant de publier sur GitHub."
    exit 1
fi
