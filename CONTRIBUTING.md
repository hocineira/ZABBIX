# Guide de Contribution

Merci de votre intérêt pour contribuer à ce projet ! Ce document vous guidera à travers le processus de contribution.

## 📋 Table des matières

- [Code de conduite](#code-de-conduite)
- [Comment contribuer](#comment-contribuer)
- [Signaler des bugs](#signaler-des-bugs)
- [Proposer des fonctionnalités](#proposer-des-fonctionnalités)
- [Soumettre des modifications](#soumettre-des-modifications)
- [Style de code](#style-de-code)
- [Tests](#tests)

## 🤝 Code de conduite

En participant à ce projet, vous vous engagez à respecter un environnement ouvert et accueillant pour tous.

## 💡 Comment contribuer

Il existe plusieurs façons de contribuer :

1. **Signaler des bugs** : Si vous trouvez un bug, ouvrez une issue
2. **Proposer des améliorations** : Vous avez une idée ? Partagez-la !
3. **Améliorer la documentation** : Corriger des fautes, clarifier des points
4. **Soumettre du code** : Corriger des bugs ou ajouter des fonctionnalités

## 🐛 Signaler des bugs

Avant de signaler un bug :
- Vérifiez qu'il n'a pas déjà été signalé dans les [issues existantes](https://github.com/votre-username/zabbix-auto-install/issues)
- Assurez-vous que vous utilisez la dernière version du script

### Template pour signaler un bug

```markdown
**Description du bug**
Description claire et concise du bug.

**Environnement**
- Distribution : [ex: Debian 13]
- Version du script : [ex: 1.0.0]
- Système de réseau : [Netplan / interfaces]

**Étapes pour reproduire**
1. Exécuter la commande '...'
2. Sélectionner l'option '...'
3. Observer l'erreur

**Comportement attendu**
Description du comportement attendu.

**Comportement observé**
Description du comportement observé.

**Logs**
```bash
# Contenu de /var/log/zabbix_installation.log
```

**Captures d'écran**
Si applicable, ajoutez des captures d'écran.
```

## ✨ Proposer des fonctionnalités

Pour proposer une nouvelle fonctionnalité :

1. Ouvrez une issue avec le tag `enhancement`
2. Décrivez clairement la fonctionnalité
3. Expliquez pourquoi elle serait utile
4. Si possible, proposez une implémentation

## 🔧 Soumettre des modifications

### 1. Fork et Clone

```bash
# Fork le projet sur GitHub, puis :
git clone https://github.com/votre-username/zabbix-auto-install.git
cd zabbix-auto-install
```

### 2. Créer une branche

```bash
git checkout -b feature/ma-nouvelle-fonctionnalite
# ou
git checkout -b fix/correction-du-bug
```

### 3. Effectuer vos modifications

- Suivez le [style de code](#style-de-code)
- Testez vos modifications
- Documentez les changements importants

### 4. Committer vos changements

```bash
git add .
git commit -m "feat: Description claire de la fonctionnalité"
# ou
git commit -m "fix: Description claire de la correction"
```

**Format des messages de commit** :
- `feat:` Nouvelle fonctionnalité
- `fix:` Correction de bug
- `docs:` Documentation seulement
- `style:` Formatage, point-virgules manquants, etc.
- `refactor:` Refactoring du code
- `test:` Ajout de tests
- `chore:` Maintenance

### 5. Pousser vers GitHub

```bash
git push origin feature/ma-nouvelle-fonctionnalite
```

### 6. Créer une Pull Request

1. Allez sur GitHub
2. Cliquez sur "New Pull Request"
3. Décrivez vos changements
4. Liez les issues concernées

## 📝 Style de code

### Bash Script

```bash
# Utiliser des noms de variables en MAJUSCULES pour les globales
GLOBAL_VAR="value"

# Utiliser des noms en minuscules pour les variables locales
local_var="value"

# Toujours utiliser des accolades pour les variables
echo "${VARIABLE}"

# Utiliser des fonctions pour organiser le code
function_name() {
    local param="$1"
    # code
}

# Commenter le code complexe
# Cette fonction fait quelque chose d'important
important_function() {
    # Explication détaillée si nécessaire
}

# Gérer les erreurs
command || error "Message d'erreur clair"

# Utiliser set -e en début de script
set -e

# Vérifier les paramètres
if [ -z "$PARAM" ]; then
    error "Paramètre manquant"
fi
```

### Documentation

- Utiliser le français pour la documentation utilisateur
- Commenter le code en français
- Être clair et concis
- Inclure des exemples quand c'est pertinent

## 🧪 Tests

Avant de soumettre votre PR :

### 1. Vérifier la syntaxe

```bash
bash -n install_zabbix.sh
```

### 2. Tester avec ShellCheck (si disponible)

```bash
shellcheck install_zabbix.sh
```

### 3. Tester dans un environnement propre

Idéalement, testez dans une VM Debian fraîche :

```bash
# Dans une VM Debian 13
sudo ./install_zabbix.sh
```

### 4. Vérifier les logs

```bash
cat /var/log/zabbix_installation.log
```

### 5. Vérifier les services

```bash
sudo systemctl status zabbix-server zabbix-agent apache2 mariadb
```

## 📚 Améliorer la documentation

La documentation est aussi importante que le code !

**Fichiers de documentation** :
- `README.md` : Documentation principale
- `NETWORK_CONFIG.md` : Configuration réseau détaillée
- `CHANGELOG.md` : Historique des changements
- `CONTRIBUTING.md` : Ce fichier

**Pour améliorer la documentation** :
1. Corrigez les fautes d'orthographe ou de grammaire
2. Clarifiez les instructions ambiguës
3. Ajoutez des exemples
4. Améliorez la mise en forme
5. Traduisez (si applicable)

## ⚡ Workflow de développement

1. **Issue** : Commencez par créer ou commenter une issue
2. **Branche** : Créez une branche depuis `develop` (ou `main`)
3. **Code** : Développez votre fonctionnalité ou correction
4. **Test** : Testez minutieusement
5. **Commit** : Committez avec des messages clairs
6. **Push** : Poussez vers votre fork
7. **PR** : Créez une Pull Request
8. **Review** : Répondez aux commentaires
9. **Merge** : Une fois approuvé, votre PR sera mergée

## 🔍 Review Process

Les PR seront reviewées selon ces critères :

- ✅ Le code fonctionne comme prévu
- ✅ Le code suit le style établi
- ✅ Les tests passent
- ✅ La documentation est à jour
- ✅ Les messages de commit sont clairs
- ✅ Pas de conflits avec la branche principale

## 🎯 Priorités actuelles

Consultez les [issues avec le label "good first issue"](https://github.com/votre-username/zabbix-auto-install/labels/good%20first%20issue) pour commencer.

**Domaines qui nécessitent de l'aide** :
- Support pour d'autres distributions (Ubuntu, CentOS)
- Tests automatisés
- Amélioration de la gestion d'erreurs
- Documentation en anglais
- Exemples d'utilisation

## 💬 Questions ?

Si vous avez des questions :
- Ouvrez une issue avec le tag `question`
- Consultez les [discussions GitHub](https://github.com/votre-username/zabbix-auto-install/discussions)

## 🙏 Remerciements

Merci à tous les contributeurs qui aident à améliorer ce projet !

---

**Happy coding! 🚀**
