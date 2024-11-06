# Script de Configuration DNS Automatisée

Ce projet propose un script Bash automatisé pour configurer et gérer des zones DNS avec BIND9 sur un serveur Linux. Il permet de configurer la résolution directe (type A) et inverse (type PTR) pour un domaine personnalisé, en plus de valider les entrées utilisateur et d'ajuster dynamiquement la largeur des tableaux d'affichage en fonction de leur contenu.

## Fonctionnalités

- **Validation des entrées** : Vérifie le format du domaine et du nameserver pour garantir la cohérence des données.
- **Installation automatique de BIND9** : Installe BIND9 et ses utilitaires s'ils ne sont pas déjà présents.
- **Création de fichiers de configuration** : Génère les fichiers de zones directes et inverses pour le domaine spécifié.
- **Mise à jour de la configuration DNS** : Configure `/etc/systemd/resolved.conf` et `/etc/bind/named.conf.default-zones` pour pointer vers le domaine et le nameserver souhaités.
- **Affichage dynamique en tableau** : Présente les informations du script avec des tableaux ajustés dynamiquement pour plus de lisibilité.
- **Tests de configuration** : Vérifie la validité des configurations et exécute des tests de résolution DNS.

## Prérequis

- **Système d'exploitation** : Linux (Ubuntu recommandé)
- **Privilèges sudo** : Nécessaire pour l'installation et la modification des fichiers système
- **BIND9** : Si non installé, le script l'installera automatiquement

## Installation

1. **Cloner le dépôt** :
   ```bash
   git clone https://github.com/whitexudan/configuration-dns
   cd configuration-dns

    Rendre le script exécutable :

chmod +x configure_dns.sh

Exécuter le script avec les paramètres souhaités :

    ./configure_dns.sh -d exemple.com -n nameserver

Utilisation

Le script accepte deux options principales :

    -d : Domaine pour lequel configurer la zone DNS (ex. exemple.com)
    -n : Nameserver, qui doit être composé uniquement de lettres de l'alphabet anglais (ex. ns1)

Exemple d'exécution

sudo ./configure_dns.sh -d exemple.com -n ns1

Sortie

Le script affiche des informations organisées dans un tableau, incluant l'adresse IP, le nom de domaine, et le nameserver. Après configuration, il effectue des tests de résolution DNS pour vérifier le bon fonctionnement.
Fonctionnalités du Script

    validate_domain : Valide le format du nom de domaine
    validate_nameserver : Vérifie que le nameserver ne contient que des lettres
    Configuration automatique : Modifie et ajuste les fichiers de configuration du DNS
    Tests de validation : Utilise nslookup pour valider les enregistrements A et PTR

Configuration et Mise à jour

Le script configure automatiquement /etc/bind/named.conf.default-zones pour inclure les zones configurées. Il gère également la mise à jour de /etc/systemd/resolved.conf pour ajouter l’adresse IP et le domaine.
Dépannage

Si le script échoue, vérifiez les points suivants :

    Permissions sudo : Assurez-vous d'avoir les droits suffisants
    BIND9 installé : Le script doit pouvoir installer BIND9 si nécessaire
    Nom de domaine valide : Vérifiez le format de votre nom de domaine et nameserver

Contributions

Les contributions sont les bienvenues ! N'hésitez pas à forker le projet, créer une branche, puis soumettre une pull request.
Licence

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.
