#!/usr/bin/bash
sudo echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sudo sysctl -p
sudo ipables-save > /tmp/iptables-save
sudo echo -e '''*nat
:PREROUTING ACCEPT [51:3004]
:INPUT ACCEPT [3:124]
:OUTPUT ACCEPT [8:700]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -o eth0 -j MASQUERADE
COMMIT''' >> /tmp/iptables-save
iptables-restore < /tmp/iptables-save
#sudo /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
# sudo yum install iptables-services
# sudo service iptables save