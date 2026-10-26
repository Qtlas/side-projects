#!/usr/bin/env bash
# install.sh for the FC Barcelona club services (DNS, DHCP, web and SFTP)
# Target OS: Ubuntu Server 22.04 or 24.04
set -euo pipefail

CLUB="fcb"
DOMAIN="fcb.wfl.lan"
SERVER_IP="172.20.131.138"
SRC="$(cd "$(dirname "$0")" && pwd)"
WWW="/var/www/${DOMAIN}"
HTPASSWD_DIR="/etc/apache2/htpasswd"

log() { echo "[$(date '+%F %T')] $*"; }
die() { echo "[ERROR] $*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || die "This script must be run as root."

# Secrets come from the environment; a local .env (see .env.example) is sourced if present.
[ -f "${SRC}/.env" ] && { set -a; . "${SRC}/.env"; set +a; }
for v in WEB_PLAYERS_PASS WEB_COACHES_PASS SFTP_PLAYERS_PASS SFTP_COACHES_PASS SFTP_ADMIN_PASS; do
    [ -n "${!v:-}" ] || die "Missing environment variable: $v (see .env.example)."
done

log "Installing packages"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y bind9 bind9utils kea-dhcp4-server kea-dhcp-ddns-server \
    apache2 apache2-utils openssh-server

log "Configuring BIND9"
install -d /etc/bind/zones
install -m 644 "${SRC}/bind/named.conf.options" /etc/bind/named.conf.options
install -m 644 "${SRC}/bind/named.conf.local"   /etc/bind/named.conf.local
install -m 640 -o root -g bind "${SRC}/bind/zones/db.${DOMAIN}" /etc/bind/zones/db.${DOMAIN}
install -m 640 -o root -g bind "${SRC}/bind/zones/db.131.20.172"       /etc/bind/zones/db.131.20.172
named-checkconf /etc/bind/named.conf
named-checkzone "${DOMAIN}" /etc/bind/zones/db.${DOMAIN}
named-checkzone "131.20.172.in-addr.arpa" /etc/bind/zones/db.131.20.172

log "Configuring Kea DHCP4 and DDNS"
install -d /etc/kea
install -m 640 -o root -g _kea "${SRC}/kea/kea-dhcp4.conf"     /etc/kea/kea-dhcp4.conf
install -m 640 -o root -g _kea "${SRC}/kea/kea-dhcp-ddns.conf" /etc/kea/kea-dhcp-ddns.conf
kea-dhcp4 -t /etc/kea/kea-dhcp4.conf

log "Configuring Apache2"
install -d "${WWW}"
cp -r "${SRC}/www/." "${WWW}/"
chown -R www-data:www-data "${WWW}"
install -d -m 750 -o root -g www-data "${HTPASSWD_DIR}"
htpasswd -cbB "${HTPASSWD_DIR}/players" players "${WEB_PLAYERS_PASS}"
htpasswd -cbB "${HTPASSWD_DIR}/coaches" coaches "${WEB_COACHES_PASS}"
chown root:www-data "${HTPASSWD_DIR}/players" "${HTPASSWD_DIR}/coaches"
chmod 640 "${HTPASSWD_DIR}/players" "${HTPASSWD_DIR}/coaches"
install -m 644 "${SRC}/apache/security-hardening.conf" /etc/apache2/conf-available/security-hardening.conf
install -m 644 "${SRC}/apache/${DOMAIN}.conf" /etc/apache2/sites-available/${DOMAIN}.conf
a2enmod headers auth_basic authn_file authz_user >/dev/null
a2enconf security-hardening >/dev/null
a2dissite 000-default.conf >/dev/null 2>&1 || true
a2ensite "${DOMAIN}.conf" >/dev/null
apache2ctl configtest

log "Configuring SFTP (OpenSSH internal-sftp, chrooted)"
groupadd -f "sftp-${CLUB}"
for role in players coaches admin; do
    id "sftp-${role}-${CLUB}" >/dev/null 2>&1 || \
        useradd -m -s /usr/sbin/nologin -G "sftp-${CLUB}" "sftp-${role}-${CLUB}"
    install -d -m 755 -o root -g root "/srv/sftp/${CLUB}/${role}"
    install -d -m 770 -o "sftp-${role}-${CLUB}" -g "sftp-${CLUB}" "/srv/sftp/${CLUB}/${role}/files"
done
echo "sftp-players-${CLUB}:${SFTP_PLAYERS_PASS}" | chpasswd
echo "sftp-coaches-${CLUB}:${SFTP_COACHES_PASS}" | chpasswd
echo "sftp-admin-${CLUB}:${SFTP_ADMIN_PASS}"     | chpasswd
install -m 644 "${SRC}/ssh/sshd_sftp.conf" /etc/ssh/sshd_config.d/sftp-${CLUB}.conf
sshd -t

log "Enabling and restarting services"
systemctl enable --now named kea-dhcp4-server kea-dhcp-ddns-server apache2 ssh >/dev/null
systemctl restart named kea-dhcp4-server kea-dhcp-ddns-server apache2 ssh

log "Status"
for s in named kea-dhcp4-server kea-dhcp-ddns-server apache2 ssh; do
    systemctl is-active --quiet "$s" && echo "  [OK] $s" || echo "  [KO] $s"
done
log "Done. Web: http://${DOMAIN}/ (training: players, tactics: coaches)."
