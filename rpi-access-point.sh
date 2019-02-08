#!/bin/sh

# RASPBERRY PI ACCESS POINT SETUP
# SIMPLE SETUP Connect to RPI wifi network
# RASPBERRY PI 3 Stretch
#
#  configure Hostapd, dns

# 1. make an executable shell script - run sudo chmod +x butter.sh
# 2. sudo sh rpi-access-point.sh.sh

# This script must be run by "sudo" and must



echo "Turn your RaspberryPi into an Access point!"
echo " ;) instant wifi"

sudo apt-get update

#Clean up. need to remove this for RPI3 stretch
sudo apt-get purge dns-root-data

#Download requirements
sudo apt-get install hostapd
yes Y | command-that-asks-for-input
sudo apt-get install dnsmasq
echo y | command

#stop during setup
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq

# modify the hostapd.conf file
sudo cat >/etc/hostapd/hostapd.conf <<-__END__
interface=wlan0
driver=nl80211
ssid=RpiScopeSpot
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=rpiscope
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
__END__

# modify the hostapd deamon
cat > /etc/default/hostapd <<-__END__
# Defaults for hostapd initscript
#
# See /usr/share/doc/hostapd/README.Debian for information about alternative
# methods of managing hostapd.
#
# Uncomment and set DAEMON_CONF to the absolute path of a hostapd configuration
# file and hostapd will be started during system boot. An example configuration
# file can be found at /usr/share/doc/hostapd/examples/hostapd.conf.gz
#
#DAEMON_CONF=""
DAEMON_CONF="/etc/hostapd/hostapd.conf"

# Additional daemon options to be appended to hostapd command:-
# 	-d   show more debug messages (-dd for even more)
# 	-K   include key data in debug messages
# 	-t   include timestamps in some debug messages
#
# Note that -B (daemon mode) and -P (pidfile) options are automatically
# configured by the init.d script and must not be added to DAEMON_OPTS.
#
#DAEMON_OPTS=""

__END__

#update the DNSmasq.conf file
#append to the end of the file new IP range clients can recieves
cat >/etc/dnsmasq.conf <<EOF
interface=wlan0
domain-needed
bogus-priv
dhcp-range=192.168.50.150,192.168.50.200,255.255.255.0,12h
EOF

# deal with legacy RPI OS networking
# clear up the /etc/network/interfaces
cat > /etc/network/interfaces <<-__END__
# interfaces(5) file used by ifup(8) and ifdown(8)
# Please note that this file is written to be used with dhcpcd
# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf'
# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d
__END__

#update the dhcpcd.conf file
#Set up the RPI WLAN0 IP address
cat >/etc/dhcpcd.conf<<__END__
# A sample configuration for dhcpcd.
# See dhcpcd.conf(5) for details.

# Allow users of this group to interact with dhcpcd via the control socket.
#controlgroup wheel

# Inform the DHCP server of our hostname for DDNS.
hostname

# Use the hardware address of the interface for the Client ID.
clientid
# or
# Use the same DUID + IAID as set in DHCPv6 for DHCPv4 ClientID as per RFC4361.
# Some non-RFC compliant DHCP servers do not reply with this set.
# In this case, comment out duid and enable clientid above.
#duid

# Persist interface configuration when dhcpcd exits.
persistent

# Rapid commit support.
# Safe to enable by default because it requires the equivalent option set
# on the server to actually work.
option rapid_commit

# A list of options to request from the DHCP server.
option domain_name_servers, domain_name, domain_search, host_name
option classless_static_routes
# Most distributions have NTP support.
option ntp_servers
# Respect the network MTU. This is applied to DHCP routes.
option interface_mtu

# A ServerID is required by RFC2131.
require dhcp_server_identifier

# Generate Stable Private IPv6 Addresses instead of hardware based ones
slaac private

# Example static IP configuration:
#interface eth0
#static ip_address=192.168.0.10/24
#static ip6_address=fd51:42f8:caae:d92e::ff/64
#static routers=192.168.0.1
#static domain_name_servers=192.168.0.1 8.8.8.8 fd51:42f8:caae:d92e::1

# It is possible to fall back to a static IP if DHCP fails:
# define static profile
#profile static_eth0
#static ip_address=192.168.1.23/24
#static routers=192.168.1.1
#static domain_name_servers=192.168.1.1

# fallback to static profile on eth0
#interface eth0
#fallback static_eth0

#interface wlan0
#static ip_address=192.168.1.77/24

nohook wpa_supplicant
interface wlan0
static ip_address=192.168.50.10/24
static routers=192.168.50.1
__END__


#For internet to be available when an Ethernet cable is attached
# cat > /etc/sysctl.conf <<-__END__
# #
# # /etc/sysctl.conf - Configuration file for setting system variables
# # See /etc/sysctl.d/ for additional system variables.
# # See sysctl.conf (5) for information.
# #

# #kernel.domainname = example.com

# # Uncomment the following to stop low-level messages on console
# #kernel.printk = 3 4 1 3

# ##############################################################3
# # Functions previously found in netbase
# #

# # Uncomment the next two lines to enable Spoof protection (reverse-path filter)
# # Turn on Source Address Verification in all interfaces to
# # prevent some spoofing attacks
# #net.ipv4.conf.default.rp_filter=1
# #net.ipv4.conf.all.rp_filter=1

# # Uncomment the next line to enable TCP/IP SYN cookies
# # See http://lwn.net/Articles/277146/
# # Note: This may impact IPv6 TCP sessions too
# #net.ipv4.tcp_syncookies=1

# # Uncomment the next line to enable packet forwarding for IPv4
# net.ipv4.ip_forward=1

# # Uncomment the next line to enable packet forwarding for IPv6
# #  Enabling this option disables Stateless Address Autoconfiguration
# #  based on Router Advertisements for this host
# #net.ipv6.conf.all.forwarding=1


# ###################################################################
# # Additional settings - these settings can improve the network
# # security of the host and prevent against some network attacks
# # including spoofing attacks and man in the middle attacks through
# # redirection. Some network environments, however, require that these
# # settings are disabled so review and enable them as needed.
# #
# # Do not accept ICMP redirects (prevent MITM attacks)
# #net.ipv4.conf.all.accept_redirects = 0
# #net.ipv6.conf.all.accept_redirects = 0
# # _or_
# # Accept ICMP redirects only for gateways listed in our default
# # gateway list (enabled by default)
# # net.ipv4.conf.all.secure_redirects = 1
# #
# # Do not send ICMP redirects (we are not a router)
# #net.ipv4.conf.all.send_redirects = 0
# #
# # Do not accept IP source route packets (we are not a router)
# #net.ipv4.conf.all.accept_source_route = 0
# #net.ipv6.conf.all.accept_source_route = 0
# #
# # Log Martian Packets
# #net.ipv4.conf.all.log_martians = 1

# __END__


# # create the file for the ip table rules
# cat >/etc/iptables-hs <<-__END__
# #!/bin/bash
# iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
# iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
# iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
# __END__

# #give persmissions to boot ip rules
# chmod +x /etc/iptables-hs

# #create systemd service file for iptable
# cat > /etc/systemd/system/hs-iptables.service <<-__END__
# [Unit]
# Description=Activate IPtables for Hotspot
# After=network-pre.target
# Before=network-online.target

# [Service]
# Type=simple
# ExecStart=/etc/iptables-hs

# [Install]
# WantedBy=multi-user.target
# __END__

# # activate service file
# systemctl enable hs-iptables


#Clean up. need to remove this for RPI3 stretch
sudo apt-get purge dns-root-data

echo "Now your PI is all ready for access point, rebooting."
sudo reboot