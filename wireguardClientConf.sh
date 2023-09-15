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

cd /etc/wireguard

if [ -f $site_name.conf ]; then
    echo "$site_name.conf already exists."
else
  echo "$site_name.conf does not exist."
  echo "[Interface]" > $site_name.conf
  echo "PrivateKey = $(cat wg-private.key)" >> $site_name.conf
  echo "Address = $client_ip" >> $site_name.conf
  echo "[Peer]" >> $site_name.conf
  echo "PublicKey = $server_public_key" >> $site_name.conf
  echo "AllowedIPs = $server_lan_ip" >> $site_name.conf
  echo "Endpoint = $server_ip:$server_port" >> $site_name.conf
  
fi