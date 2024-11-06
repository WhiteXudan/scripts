# DNS Configuration Script - dns.sh

Ce script permet de modifier automatiquement le fichier de configuration `/etc/systemd/resolved.conf` en ajoutant ou en remplaçant les informations de domaine et de serveur DNS. Il garantit ainsi une configuration DNS à jour et centralisée.

## Exemple d'utilisation

Lancez le script avec la commande suivante pour ajouter ou remplacer les informations DNS et de domaine :

./dns.sh -d lux.com -n 192.168.20.46 &

Cette commande ajoutera ou remplacera les informations de domaine et de serveur DNS dans le fichier `/etc/systemd/resolved.conf`.

## Installation

1. Clonez le dépôt dans votre répertoire local :

git clone https://github.com/votre-utilisateur/votre-depot.git

2. Rendez le script exécutable :

chmod +x dns.sh

3. Ajoutez le script dans votre `$PATH` pour y accéder facilement.

## Configuration

Le script modifie automatiquement le fichier `/etc/systemd/resolved.conf` pour inclure les informations DNS spécifiées. Si l’adresse DNS change, le script remplace l’ancienne adresse par la nouvelle sans demander de saisie de domaine ou de serveur DNS.

## License

Ce projet est sous licence MIT. Consultez le fichier LICENSE pour plus de détails.

## Contribution

Les contributions sont les bienvenues ! N'hésitez pas à soumettre une issue ou une pull request pour toute amélioration ou fonctionnalité supplémentaire.

Note : Ce script est fourni "tel quel" sans garantie de fonctionnement pour des configurations spécifiques. Utilisez-le avec précaution et en sachant qu'il modifiera vos configurations DNS.
