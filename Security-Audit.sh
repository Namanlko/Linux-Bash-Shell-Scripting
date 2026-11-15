#!/usr/bin/env bash
# ============================================================
# Script Name : Security-Audit.sh
# Description : READ-ONLY baseline security check for a Linux server
#               (SSH config, firewall, privileged accounts, file
#               permissions, auto-updates, listening ports).
#               Inspired by common CIS-style checks - not a full benchmark.
# Usage       : sudo ./Security-Audit.sh     (root gives the most complete results)
# Exit codes  : 0 = no failures, 1 = at least one FAIL
# Author      : Naman Pandey
# ============================================================

set -uo pipefail

PASS=0; WARNS=0; FAILS=0
pass() { echo "🟢 PASS  $1"; PASS=$((PASS + 1)); }
warn() { echo "🟡 WARN  $1"; WARNS=$((WARNS + 1)); }
fail() { echo "🔴 FAIL  $1"; FAILS=$((FAILS + 1)); }
info() { echo "ℹ️  INFO  $1"; }
section() { echo; echo "── $1"; }

IS_ROOT=false
[ "$(id -u)" -eq 0 ] && IS_ROOT=true

echo "=========================================="
echo "   🛡️  SECURITY AUDIT  ($(hostname))"
echo "   $(date '+%F %T')"
echo "=========================================="
$IS_ROOT || echo "ℹ️  Not running as root - some checks will be skipped."

# Read an sshd setting: effective value via 'sshd -T' (root), else from config files
sshd_value() {
    local key=$1 val=""
    if $IS_ROOT && command -v sshd &>/dev/null; then
        val=$(sshd -T 2>/dev/null | awk -v k="$(echo "$key" | tr 'A-Z' 'a-z')" '$1 == k {print $2}')
    fi
    if [ -z "$val" ]; then
        val=$(grep -hiE "^\s*$key\s+" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf 2>/dev/null \
              | head -1 | awk '{print tolower($2)}')
    fi
    echo "${val:-unset}"
}

section "SSH"
if [ -f /etc/ssh/sshd_config ]; then
    v=$(sshd_value PermitRootLogin)
    case "$v" in
        no|prohibit-password|without-password) pass "Root SSH login restricted (PermitRootLogin $v)" ;;
        yes)   fail "Root SSH login is allowed (PermitRootLogin yes)" ;;
        *)     warn "PermitRootLogin not set explicitly (OpenSSH default applies)" ;;
    esac
    v=$(sshd_value PasswordAuthentication)
    case "$v" in
        no)  pass "Password authentication disabled (key-only)" ;;
        yes) warn "Password authentication enabled - prefer SSH keys" ;;
        *)   warn "PasswordAuthentication not set explicitly (default is yes)" ;;
    esac
else
    info "No sshd_config found - SSH server not installed?"
fi

section "Firewall"
if command -v ufw &>/dev/null && ufw status 2>/dev/null | grep -q "Status: active"; then
    pass "UFW firewall is active"
elif command -v firewall-cmd &>/dev/null && firewall-cmd --state 2>/dev/null | grep -q running; then
    pass "firewalld is running"
elif $IS_ROOT && command -v iptables &>/dev/null && [ "$(iptables -S 2>/dev/null | wc -l)" -gt 3 ]; then
    pass "iptables rules are present"
else
    warn "No active firewall detected (or insufficient permissions to check)"
fi

section "Accounts"
extra_root=$(awk -F: '$3 == 0 && $1 != "root" {print $1}' /etc/passwd)
if [ -z "$extra_root" ]; then pass "Only 'root' has UID 0"
else fail "Extra UID 0 accounts: $extra_root"; fi

if $IS_ROOT; then
    empty=$(awk -F: '$2 == "" {print $1}' /etc/shadow)
    if [ -z "$empty" ]; then pass "No accounts with empty passwords"
    else fail "Accounts with EMPTY password: $empty"; fi
else
    info "Skipped empty-password check (needs root)"
fi

for grp in sudo wheel; do
    members=$(getent group "$grp" 2>/dev/null | cut -d: -f4)
    [ -n "$members" ] && info "Members of '$grp' group: $members"
done

section "Files"
ww=$(find /etc -xdev -type f -perm -0002 2>/dev/null | head -5)
if [ -z "$ww" ]; then pass "No world-writable files in /etc"
else fail "World-writable files in /etc:"; echo "$ww" | sed 's/^/          /'; fi

[ "$(stat -c '%a' /etc/passwd 2>/dev/null)" = "644" ] && pass "/etc/passwd permissions are 644" || warn "/etc/passwd permissions differ from 644"
shadow_perm=$(stat -c '%a' /etc/shadow 2>/dev/null)
case "$shadow_perm" in
    600|640|000|400|"") pass "/etc/shadow permissions are restrictive (${shadow_perm:-unreadable})" ;;
    *) fail "/etc/shadow permissions too open ($shadow_perm)" ;;
esac

section "Updates"
if dpkg -l unattended-upgrades 2>/dev/null | grep -q '^ii'; then pass "unattended-upgrades is installed"
elif rpm -q dnf-automatic &>/dev/null; then pass "dnf-automatic is installed"
else warn "No automatic security updates configured"; fi

section "Listening ports (review anything unexpected)"
if command -v ss &>/dev/null; then
    ss -tulnH | awk '{printf "   %-5s %s\n", $1, $5}' | sort -u
fi

echo
echo "=========================================="
echo "Summary: 🟢 $PASS passed   🟡 $WARNS warnings   🔴 $FAILS failed"
echo "=========================================="
[ "$FAILS" -eq 0 ]
