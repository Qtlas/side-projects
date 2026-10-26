#!/usr/bin/env bash
# install.sh for the WFL backbone services (BIND9 DNS and Chrony NTP)
# Target OS: Ubuntu Server 22.04 or 24.04
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
log() { echo "[$(date '+%F %T')] $*"; }
die() { echo "[ERROR] $*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || die "This script must be run as root."

log "Installing packages"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y bind9 bind9utils chrony

log "Configuring BIND9"
install -d /etc/bind/zones
install -m 644 "${SRC}/bind/named.conf.options" /etc/bind/named.conf.options
install -m 644 "${SRC}/bind/named.conf.local"   /etc/bind/named.conf.local
install -m 640 -o root -g bind "${SRC}/bind/zones/db.wfl.lan"    /etc/bind/zones/db.wfl.lan
install -m 640 -o root -g bind "${SRC}/bind/zones/db.128.20.172" /etc/bind/zones/db.128.20.172
named-checkconf /etc/bind/named.conf
named-checkzone wfl.lan /etc/bind/zones/db.wfl.lan
named-checkzone 128.20.172.in-addr.arpa /etc/bind/zones/db.128.20.172

log "Configuring Chrony"
install -m 644 "${SRC}/chrony/chrony.conf" /etc/chrony/chrony.conf

log "Enabling and restarting services"
systemctl enable --now named chrony >/dev/null
systemctl restart named chrony

log "Status"
for s in named chrony; do
    systemctl is-active --quiet "$s" && echo "  [OK] $s" || echo "  [KO] $s"
done
log "Backbone services installed."
