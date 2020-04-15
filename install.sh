#Update System

apt update
clear

apt upgrade -y

clear

#Installation AP and other utilities

apt install hostapd dnsmasq -y

clear

# define configuration files

echo "denyinterfaces wlan0" >> /etc/dhcpcd.conf

mv /etc/network/interfaces /etc/network/interfaces.bak

echo "source-directory /etc/network/interfaces.d

allow-hotplug eth0
iface eth0 inet dhcp

allow-hotplug wlan0
iface wlan0 inet static
    address 10.0.0.1
    netmask 255.255.255.0
    network 10.0.0.0
    broadcast 10.0.0.255" > /etc/network/interfaces
	
echo "
interface=wlan0
driver=nl80211
ssid=MyPiAP
hw_mode=g
channel=6
ieee80211n=1
wmm_enabled=1
ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40]
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_passphrase=raspberry
rsn_pairwise=CCMP" > /etc/hostapd/hostapd.conf

echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> /etc/default/hostapd

mv /etc/dnsmasq.conf /etc/dnsmasq.conf.bak

echo "interface=wlan0 
listen-address=10.0.0.1
bind-interfaces 
server=8.8.8.8
domain-needed
bogus-priv
dhcp-range=10.0.0.100,10.0.0.200,24h" > /etc/dnsmasq.conf

sed -i -e "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g" /etc/sysctl.conf



clear

# Installation DDserver


apt-get install build-essential pkg-config libusb-1.0-0-dev git -y
git clone git://github.com/hubaiz/DslrDashboardServer package/DslrDashboardServer
g++ -Wall /home/pi/package/DslrDashboardServer/src/main.cpp /home/pi/package/DslrDashboardServer/src/communicator.cpp `pkg-config --libs --cflags libusb-1.0` -lpthread -lrt -lstdc++ -o ddserver

#installation service DDserver

echo " [Unit]
 Description=DDserveur Launch at boot
 After=multi-user.target

 [Service]
 Type=simple
 ExecStart=/home/pi/ddserver

 [Install]
 WantedBy=multi-user.target" > /lib/systemd/system/ddserver.service
 
 chmod 644 /lib/systemd/system/ddserver.service
 
 systemctl daemon-reload
 
 systemctl enable ddserver.service


# End file configuration and reboot rpi

systemctl unmask hostapd
systemctl enable hostapd
systemctl reboot
