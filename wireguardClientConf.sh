sudo apt update && sudo apt upgrade -y

# we install wireguard client if not installed
if [ -f /usr/bin/wg ]; then
    echo "Wireguard already installed."
else
  echo "Wireguard not installed."
  sudo apt install wireguard -y
fi


# we create the client keys pair

if [ -f wg-private.key ]; then
    echo "wg-private.key already exists."
else
  echo "wg-private.key does not exist."
  (umask 077 && wg genkey > wg-private.key)
  wg pubkey < wg-private.key > wg-public.key
fi


# we create the client config file
read -p "Enter the site name: [Max 8 chars] " site_name
read -p "Enter the server IP: " server_ip
read -p "Enter the servers LAN Network IP [ex : 10.72.x.128/25]: " server_lan_ip
read -p "Enter the server public key: " server_public_key
read -p "Enter the server port [default : 51820]: " server_port
read -p "Enter the client IP: " client_ip


if [ -f /etc/wireguard/$site_name.conf ]; then
    echo "/etc/wireguard/$site_name.conf already exists."
else

  echo "Use The following public key to configure the client on firewall:"
  cat ./wg-public.key
  pause

  echo "/etc/wireguard/$site_name.conf does not exist."
  echo "[Interface]" > /etc/wireguard/$site_name.conf
  echo "PrivateKey = $(cat wg-private.key)" >> /etc/wireguard/$site_name.conf
  echo "Address = $client_ip" >> /etc/wireguard/$site_name.conf
  echo "[Peer]" >> /etc/wireguard/$site_name.conf
  echo "PublicKey = $server_public_key" >> /etc/wireguard/$site_name.conf
  echo "AllowedIPs = $server_lan_ip" >> /etc/wireguard/$site_name.conf
  echo "Endpoint = $server_ip:$server_port" >> /etc/wireguard/$site_name.conf
  
  echo "Your client config file is ready in /etc/wireguard/$site_name.conf"
  echo "To enable the client, run the following command:"
  echo "sudo wg-quick up $site_name"
  echo "To disable the client, run the following command:"
  echo "sudo wg-quick down $site_name"
  echo "To check the status of the client, run the following command:"
  echo "sudo wg show"
  

fi