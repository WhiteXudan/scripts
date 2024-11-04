#!/bin/bash

# Informations du script
scriptName="Configuration de DNS (BIND9)"
author="Auteur : [Ton Nom]"
version="Version : 1.0"
date="Date : $(date +'%d/%m/%Y')"

# Couleurs pour les informations
bold=$(tput bold)
blue="\e[34m"
reset="\e[0m"

#!/bin/bash

# Informations du script
scriptName="Configuration de DNS (BIND9)"
author="Auteur : [whitexudan]"
version="Version : 1.0"
date="Date : $(date +'%d/%m/%Y')"

# Couleurs pour les informations
bold=$(tput bold)
blue="\e[34m"
reset="\e[0m"

# Calcul des longueurs pour ajuster la largeur de la table dynamiquement
maxLength=$(printf "%s\n" "$scriptName" "$author" "$version" "$date" | awk '{ if (length > L) L = length } END { print L }')
totalWidth=$((maxLength + 2))  # Ajustement de la largeur pour éviter le débordement

# Affichage de l'en-tête avec le style de tableau et les couleurs
printf "+%s+\n" "$(head -c $totalWidth < /dev/zero | tr '\0' '-')"
printf "| ${bold}${blue}%-${maxLength}s${reset} |\n" "$scriptName"
printf "+%s+\n" "$(head -c $totalWidth < /dev/zero | tr '\0' '-')"
printf "| ${blue}%-${maxLength}s${reset} |\n" "$author"
printf "| ${blue}%-${maxLength}s${reset} |\n" "$version"
printf "| ${blue}%-${maxLength}s${reset} |\n" "$date"
printf "+%s+\n" "$(head -c $totalWidth < /dev/zero | tr '\0' '-')"
echo



# Variables
ip=$(hostname -I | awk '{print $1}')  # Récupération de l'adresse IP (première interface)
ipQ=$(echo "$ip" | cut -d '.' -f 4)     # Dernier octet pour PTR
ipPTR=$(echo "$ip" | awk -F. '{print $3"."$2"."$1}')  # Format inverse

# Vérification de l'installation de BIND9
if [ ! -d /etc/bind ]; then
    echo -e "BIND9 is not installed... Let's install it...\n"
    echo -e "Would you want me to install BIND9 ? (Y/n) : "
    read YesOrNo
    if [[ "$YesOrNo" =~ ^[Yy]$ ]]; then
        sudo apt update && sudo apt install -y bind9 bind9utils
    else
        exit 0
    fi
else
    echo -e "OK! bind9 is already installed...\n"
fi

echo -e "#################\n# CONFIGURATION #\n#################\n"

# Fonction pour vérifier le format du domaine
validate_domain() {
    [[ "$1" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{1,61}[a-zA-Z0-9])?\.[a-zA-Z]{2,}$ ]]
}

# Demande de saisie pour le nom de domaine
while true; do
    read -p "Domain name (ex: exemple.com) : " nomDeDomaine
    if [[ -z "$nomDeDomaine" ]]; then
        echo -e "Veuillez saisir votre domaine.\n"
    elif ! validate_domain "$nomDeDomaine"; then
        echo -e "Format valide : \e[1mexemple.com\e[0m\n"
    else
        break
    fi
done

# Demande de saisie pour le nom du serveur
while true; do
    read -p "Name Server (ex: ns1) : " namserver
    if [[ -z "$namserver" ]]; then
        echo -e "Veuillez saisir le nom du serveur \n"
    else
        break
    fi
done

echo -e "\n"

# Calcul des longueurs des éléments
ipLength=${#ip}
domainLength=${#nomDeDomaine}
nameserverLength=${#namserver}

# Calculer pour que la largeur du tableau tienne compte de l'élément le plus long
maxIpLength=$((ipLength > 13 ? ipLength : 13))
maxDomainLength=$((domainLength > 13 ? domainLength : 13))
maxNameserverLength=$((nameserverLength > 13 ? nameserverLength : 13))

# Calcul de la largeur totale de la table
totalWidth=$((maxIpLength + maxDomainLength + maxNameserverLength + 8))

# Affichage des informations sous forme de tableau avec des '-' et '+'
printf "+%s+\n" "$(head -c $totalWidth < /dev/zero | tr '\0' '-')"
printf "| %-${maxIpLength}s | %-${maxDomainLength}s | %-${maxNameserverLength}s |\n" "IP ADDRESS" "DOMAIN NAME" "NAMESERVER"
printf "+%s+\n" "$(head -c $totalWidth < /dev/zero | tr '\0' '-')"
printf "| \e[34m%-${maxIpLength}s\e[0m | \e[34m%-${maxDomainLength}s\e[0m | \e[34m%-${maxNameserverLength}s\e[0m |\n" "$ip" "$nomDeDomaine" "$namserver"
printf "+%s+\n" "$(head -c $totalWidth < /dev/zero | tr '\0' '-')"
echo -e "\n"


# Noms de fichiers de configuration
direct_conf="/etc/bind/$nomDeDomaine"
inv_conf="/etc/bind/$(echo "$nomDeDomaine" | sed 's/\.[^.]*$/.inv/')"

# Créer les fichiers de configuration si nécessaires
for conf in "$direct_conf" "$inv_conf"; do
    if [ ! -f "$conf" ]; then
        echo "Creating the configuration file: $conf..."
        sudo touch "$conf"
        sudo chmod u+rw,g+rw "$conf"  # Permissions pour l'utilisateur et le groupe
    fi
done

# Configuration DIRECT (A)
echo -e "Configuring the direct resolution (type A)..."
{
    echo -e ";"
    echo -e "; BIND data file for local loopback interface"
    echo -e ";"
    echo -e "\$TTL	604800"
    echo -e "@	IN	SOA	$namserver.$nomDeDomaine. root.$nomDeDomaine. ("
    echo -e "			      2		; Serial"
    echo -e "			 604800		; Refresh"
    echo -e "			  86400		; Retry"
    echo -e "			2419200		; Expire"
    echo -e "			 604800 )	; Negative Cache TTL"
    echo -e ";"
    echo -e "@	IN	NS	$namserver.$nomDeDomaine."
    echo -e "$namserver	IN	A	$ip"
} | sudo tee "$direct_conf" > /dev/null

# Configuration INVERSE (PTR)
echo -e "Configuring the inverse resolution (type PTR)...\n"
{
    echo -e ";"
    echo -e "; BIND data file for local loopback interface"
    echo -e ";"
    echo -e "\$TTL	604800"
    echo -e "@	IN	SOA	$namserver.$nomDeDomaine. root.$nomDeDomaine. ("
    echo -e "			      2		; Serial"
    echo -e "			 604800		; Refresh"
    echo -e "			  86400		; Retry"
    echo -e "			2419200		; Expire"
    echo -e "			 604800 )	; Negative Cache TTL"
    echo -e ";"
    echo -e "@	IN	NS	$namserver.$nomDeDomaine."
    echo -e "$ipQ	IN	PTR	$namserver.$nomDeDomaine."
} | sudo tee "$inv_conf" > /dev/null

# Mise à jour de la configuration DNS dans /etc/bind/named.conf.default-zones
echo -e "Configuring DNS default-zones in /etc/bind/named.conf.default-zones ...\n"
{
    echo -e "// prime the server with knowledge of the root servers"
    echo -e "zone \".\" {"
    echo -e "	type hint;"
    echo -e "	file \"/usr/share/dns/root.hints\";"
    echo -e "};"
    echo -e ""
    echo -e "// be authoritative for the localhost forward and reverse zones, and for"
    echo -e "// broadcast zones as per RFC 1912"
    echo -e ""
    echo -e "zone \"$nomDeDomaine\" {"
    echo -e "	type master;"
    echo -e "	file \"$direct_conf\";"
    echo -e "};"
    echo -e ""
    echo -e "zone \"$ipPTR.in-addr.arpa\" {"
    echo -e "	type master;"
    echo -e "	file \"$inv_conf\";"
    echo -e "};"
    echo -e ""
    echo -e "zone \"0.in-addr.arpa\" {"
    echo -e "	type master;"
    echo -e "	file \"/etc/bind/db.0\";"
    echo -e "};"
    echo -e ""
    echo -e "zone \"255.in-addr.arpa\" {"
    echo -e "	type master;"
    echo -e "	file \"/etc/bind/db.255\";"
    echo -e "};"
} | sudo tee /etc/bind/named.conf.default-zones > /dev/null

# Mise à jour de resolv.conf
if [ -f /etc/systemd/resolved.conf ]; then
    echo -e "Updating DNS configurations in /etc/systemd/resolved.conf...\n"
    
    # Vérification et mise à jour de l'adresse DNS
    if ! grep -q "^DNS=.*$ip" /etc/systemd/resolved.conf; then
        if grep -q "^DNS=" /etc/systemd/resolved.conf; then
            # Si DNS existe déjà, ajouter avec un espace
            sudo sed -i "s/^DNS=\(.*\)/DNS=\1 $ip/" /etc/systemd/resolved.conf
        else
            # Si DNS n'existe pas, ajouter sans espace
            sudo sed -i "s/^#*DNS=/DNS=$ip/" /etc/systemd/resolved.conf
        fi
    else
        echo -e "DNS \e[34m$ip\e[0m is already added.\n"
    fi

    # Vérification et mise à jour de l'adresse FallbackDNS
    if ! grep -q "^FallbackDNS=.*8.8.8.8" /etc/systemd/resolved.conf; then
        sudo sed -i '/^#*FallbackDNS=/s/^#//; /^FallbackDNS=/s/$/ 8.8.8.8/' /etc/systemd/resolved.conf
    else
        echo -e "FallbackDNS \e[34m8.8.8.8\e[0m is already added.\n"
    fi

    # Vérification et mise à jour du domaine
    if ! grep -q "^Domains=.*$nomDeDomaine" /etc/systemd/resolved.conf; then
        if grep -q "^Domains=" /etc/systemd/resolved.conf; then
            # Si Domains existe déjà, ajouter avec un espace
            sudo sed -i "s/^Domains=\(.*\)/Domains=\1 $nomDeDomaine/" /etc/systemd/resolved.conf
        else
            # Si Domains n'existe pas, ajouter sans espace
            sudo sed -i "s/^#*Domains=/Domains=$nomDeDomaine/" /etc/systemd/resolved.conf
        fi
    else
        echo -e "Domain \e[34m$nomDeDomaine\e[0m is already added.\n"
    fi

    sudo systemctl restart systemd-resolved
else
    echo -e "/etc/systemd/resolved.conf not found; \nInstalling Systemd-resolved....\n"
    sudo apt install systemd-resolved -y
    sudo rm /etc/resolv.conf
    sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
    echo -e "\n"
    echo "Updating DNS configurations in /etc/systemd/resolved.conf..."
    
    # Mise à jour des configurations après installation
    sudo sed -i "s/^#*DNS=/DNS=$ip/" /etc/systemd/resolved.conf
    sudo sed -i '/^#*FallbackDNS=/s/^#//; /^FallbackDNS=/s/$/ 8.8.8.8/' /etc/systemd/resolved.conf
    sudo sed -i "s/^#*Domains=/Domains=$nomDeDomaine/" /etc/systemd/resolved.conf
    sudo systemctl restart systemd-resolved
fi

# Vérification de la configuration
echo -e "Verifying BIND9 configuration...\n"
if named-checkconf; then
    echo "BIND9 configuration is valid..."
    	# Finalisation
	sudo systemctl restart bind9.service
	echo -e "\nBIND9 configuration completed.\n"

	# Ajoutez ceci à la fin de votre script existant
	echo -e "Testing...\n"

	# Test pour le type A
	echo -e "\e[1;34m[Type A]\e[0m\n"
	if nslookup "$namserver.$nomDeDomaine"; then
	    echo -e "\e[1mSuccess:\e[0m The A record for \e[34m$namserver.$nomDeDomaine\e[0m was found.\n"
	    a_record_status="Success"
	else
	    echo -e "\e[1mError:\e[0m The A record for \e[34m$namserver.$nomDeDomaine\e[0m could not be found.\n"
	    a_record_status="Failure"
	fi

	# Test pour le type PTR
	echo -e "\e[1;34m[Type PTR]\e[0m\n"
	if nslookup "$ip"; then
	    echo -e "\e[1mSuccess:\e[0m The PTR record for \e[34m$ip\e[0m was found."
	    ptr_record_status="Success"
	else
	    echo -e "\e[1mError:\e[0m The PTR record for \e[34m$ip\e[0m could not be found."
	    ptr_record_status="Failure"
	fi

	# Affichage du tableau de résultats
	echo
	total_successful=0
	error_message=""

	if [[ "$a_record_status" == "Success" ]]; then
	    total_successful=$((total_successful + 1))
	else
	    error_message="A record resolution failed."
	fi

	if [[ "$ptr_record_status" == "Success" ]]; then
	    total_successful=$((total_successful + 1))
	else
	    error_message="PTR record resolution failed."
	fi

	# Déterminer la largeur maximale du tableau
	if [[ $total_successful -eq 2 ]]; then
	    result_message="Successful"
	else
	    result_message="$error_message"
	fi

	# Calculer la largeur de la ligne (sans débordement)
	table_width=$(( ${#result_message} + 2 ))  # 2 pour les espaces

	# Affichage du tableau de succès
	printf "+%s+\n" "$(printf "%-${table_width}s" "" | tr ' ' '-')"  # Ligne supérieure
	echo -e "| \e[1;32m$result_message\e[0m |"  # Message de résultat
	printf "+%s+\n" "$(printf "%-${table_width}s" "" | tr ' ' '-')"  # Ligne inférieure
else
    echo "BIND9 configuration has errors."
    exit 1
fi

