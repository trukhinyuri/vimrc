#!/bin/bash
#
echo "Installing wildfly"

#lib_________________________
function checkOK {
    if [ "$?" -ne 0 ]; then
        echo "Error, sorry."
        exit 0
    fi
}
function checkCentOSUpdates {
    yum -y update
    checkOK
}
function firewallConfig {
#
# iptables example configuration script
#
# Flush all current rules from iptables
#
 iptables -F
#
# Allow SSH connections on tcp port 22
# This is essential when working on remote servers via SSH to prevent locking yourself out of the system
#
 iptables -A INPUT -p tcp --dport 22 -j ACCEPT
 iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
iptables -A INPUT -p tcp --dport 9990 -j ACCEPT
#
# Set default policies for INPUT, FORWARD and OUTPUT chains
#
 iptables -P INPUT DROP
 iptables -P FORWARD DROP
 iptables -P OUTPUT ACCEPT
#
# Set access for localhost
#
 iptables -A INPUT -i lo -j ACCEPT
#
# Accept packets belonging to established and related connections
#
 iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
#
# Save settings
#
 /sbin/service iptables save
#
# List rules
#
 iptables -L -v
}
function installJDK7u45 {
    cd ~
    wget -O jdk-7u45-linux-x64.rpm --no-check-certificate --no-cookies --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com" "http://download.oracle.com/otn-pub/java/jdk/7u45-b18/jdk-7u45-linux-x64.rpm"
    checkOK
    rpm -ivh jdk-7u45-linux-x64.rpm
#    checkOK //Java may be installed
    rm jdk-7u45-linux-x64.rpm
    checkOK
}
function open8080Port {
    iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 8080 -j ACCEPT -m comment --comment "Wildfly server port"
    iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 9990 -j ACCEPT -m comment --comment "WildFly admin port"
    service iptables save 
}
function installWildFly8CR1 {
    cd /usr/share
    wget http://download.jboss.org/wildfly/8.0.0.CR1/wildfly-8.0.0.CR1.tar.gz
    checkOK
    tar zxf wildfly-8.0.0.CR1.tar.gz
    checkOK
    ln -sf /usr/share/wildfly-8.0.0.CR1/ /usr/share/wildfly
    cd /usr/share/wildfly/bin
    chmod +x standalone.sh
    checkOK
    chmod +x domain.sh
    checkOK
}
function runWildFly8 {
    cd /usr/share/wildfly/bin
    curl ifconfig.me
    ./standalone.sh -b=$?  &
    echo "Running Wildfly... Happy Coding! (http://infoboxcloud.com)"
}
#endlib______________________

#checkCentOSUpdates
installJDK7u45
installWildFly8CR1
#firewallConfig
open8080Port
runWildFly8
