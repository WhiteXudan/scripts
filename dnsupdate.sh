############ FONCTIONS #############
# Fonction pour récupérer l'adresse IP
get_ip() {
    echo $(hostname -I | awk '{print $1}')
}

# Fonction pour mettre à jour les fichiers de configuration
update_dns_config() {
    nouvelIp=$(get_ip)
    nouvelIpQ=$(echo "$ip" | cut -d '.' -f 4)
    nouvelIpPTR=$(echo "$ip" | awk -F. '{print $3"."$2"."$1}') 

    # Configuration DIRECT (A)
    echo -e "Configuring the direct resolution (type A)..."
    {
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
        echo -e "$namserver	IN	A	$nouvelIp"
    } | sudo tee "/etc/bind/$nomDeDomaine" > /dev/null

    # Configuration INVERSE (PTR)
    echo -e "Configuring the inverse resolution (type PTR)..."
    {
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
        echo -e "$nouvelIpQ	IN	PTR	$namserver.$nomDeDomaine."
    } | sudo tee "/etc/bind/$(echo "$nomDeDomaine" | sed 's/\.[^.]*$/.inv/')" > /dev/null

    # Mise à jour de la configuration DNS dans /etc/systemd/resolved.conf
    if [ -f /etc/systemd/resolved.conf ]; then
        echo -e "Updating DNS configurations in /etc/systemd/resolved.conf...\n"
        
        # Vérification et mise à jour de l'adresse DNS
        if ! grep -q "^DNS=.*$nouvelIp" /etc/systemd/resolved.conf; then
            if grep -q "^DNS=" /etc/systemd/resolved.conf; then
                sudo sed -i "s/^DNS=\(.*\)/DNS=\1 $nouvelIp/" /etc/systemd/resolved.conf
            else
                sudo sed -i "s/^#*DNS=/DNS=$nouvelIp/" /etc/systemd/resolved.conf
            fi
        else
            echo -e "DNS \e[34m$nouvelIp\e[0m is already added.\n"
        fi

        # Vérification et mise à jour du domaine
        if ! grep -q "^Domains=.*$nomDeDomaine" /etc/systemd/resolved.conf; then
            if grep -q "^Domains=" /etc/systemd/resolved.conf; then
                sudo sed -i "s/^Domains=\(.*\)/Domains=\1 $nomDeDomaine/" /etc/systemd/resolved.conf
            else
                sudo sed -i "s/^#*Domains=/Domains=$nomDeDomaine/" /etc/systemd/resolved.conf
            fi
        else
            echo -e "Domain \e[34m$nomDeDomaine\e[0m is already added.\n"
        fi

        sudo systemctl restart systemd-resolved
    fi
}

####################################



# Boucle de surveillance de l'adresse IP
while true; do
    nouvelIp=$(get_ip)
    
    if [ "$nouvelIp" != "$ip" ]; then
        echo "L'adresse IP DNS a changé : $nouvelIp"
        update_dns_config
        sudo systemctl restart bind9.service
    fi
    
    sleep 30  # Vérifie toutes les 10 secondes (ajuste si nécessaire)
done
