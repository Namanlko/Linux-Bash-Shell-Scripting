#!/usr/bin/env bash
# ============================================================
# Script Name : SSL-Expiry-Check.sh
# Description : Reports how many days are left on the TLS certificate
#               of one or more hosts. Handy as a daily cron job.
# Usage       : ./SSL-Expiry-Check.sh [-p port] [-w warn_days] host1 host2 ...
# Example     : ./SSL-Expiry-Check.sh -w 21 google.com github.com
# Exit codes  : 0 = all fine, 1 = expiring soon, 2 = expired / unreachable
# Author      : Naman Pandey
# ============================================================

set -uo pipefail

PORT=443
WARN_DAYS=30

while getopts "p:w:h" opt; do
    case "$opt" in
        p) PORT=$OPTARG ;;
        w) WARN_DAYS=$OPTARG ;;
        *) echo "Usage: $0 [-p port] [-w warn_days] host..."; exit 3 ;;
    esac
done
shift $((OPTIND - 1))

[ $# -ge 1 ] || { echo "Usage: $0 [-p port] [-w warn_days] host..."; exit 3; }
command -v openssl &>/dev/null || { echo "❌ openssl is required"; exit 3; }

STATUS=0
bump() { (( STATUS < $1 )) && STATUS=$1; }

printf "%-30s %-26s %s\n" "HOST" "EXPIRES" "STATUS"
echo "---------------------------------------------------------------------------"

for host in "$@"; do
    end=$(echo | timeout 10 openssl s_client -servername "$host" -connect "$host:$PORT" 2>/dev/null \
          | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)

    if [ -z "$end" ]; then
        printf "%-30s %-26s %s\n" "$host" "-" "❌ could not fetch certificate"
        bump 2
        continue
    fi

    days=$(( ( $(date -d "$end" +%s) - $(date +%s) ) / 86400 ))

    if   (( days < 0 ));          then msg="🔴 EXPIRED $((-days)) days ago"; bump 2
    elif (( days < WARN_DAYS ));  then msg="🟡 ${days} days left (renew soon)"; bump 1
    else                               msg="🟢 ${days} days left"
    fi
    printf "%-30s %-26s %s\n" "$host" "$end" "$msg"
done

exit "$STATUS"
