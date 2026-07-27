#!/usr/bin/env bash
################################################################################
#
# Copyright (C) BadPixxel <www.badpixxel.com>
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
################################################################################
#
# Sync the fixed IPs / hostnames declared in a docker-compose file into
# the local /etc/hosts, so that "toolkit.bms.local" & friends resolve on
# the host machine during development.
#
# It reads every  `ipv4_address` + `aliases`  pair from the compose file,
# compares them with /etc/hosts and reports, for each host:
#
#     [ OK  ]  already present with the right IP        -> nothing to do
#     [ ADD ]  missing                                  -> line appended
#     [ FIX ]  present but pointing to a different IP   -> line replaced
#
# Usage:
#     bash docker-ips.sh [--dry-run] [--yes] [FILE]
#
#         --dry-run   only print the plan, never touch /etc/hosts
#         --yes, -y   apply without the interactive confirmation
#         FILE        compose file (default: auto-detected in CWD)
#
################################################################################

set -euo pipefail

################################################################################
# Colors (disabled when output is not a terminal)
if [ -t 1 ]; then
    C_RESET=$'\033[0m'; C_DIM=$'\033[2m'; C_BOLD=$'\033[1m'
    C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_RED=$'\033[31m'; C_CYAN=$'\033[36m'
else
    C_RESET=; C_DIM=; C_BOLD=; C_GREEN=; C_YELLOW=; C_RED=; C_CYAN=
fi

################################################################################
# Parse arguments
DRY_RUN=0
ASSUME_YES=0
COMPOSE_FILE=""

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        --yes|-y)  ASSUME_YES=1 ;;
        -*)        echo "Unknown option: $arg" >&2; exit 2 ;;
        *)         COMPOSE_FILE="$arg" ;;
    esac
done

################################################################################
# Locate the compose file
if [ -z "$COMPOSE_FILE" ]; then
    for candidate in docker-compose.yml docker-compose.yaml compose.yml compose.yaml; do
        if [ -f "$candidate" ]; then COMPOSE_FILE="$candidate"; break; fi
    done
fi

if [ -z "$COMPOSE_FILE" ] || [ ! -f "$COMPOSE_FILE" ]; then
    echo "${C_RED}No docker compose file found in $(pwd).${C_RESET}" >&2
    exit 1
fi

################################################################################
# Extract "IP<TAB>host" pairs from every `ipv4_address` + `aliases` line.
#
# Matches the inline flow style used across our projects, e.g.:
#     bms: { ipv4_address: 172.118.4.100, aliases: [ toolkit.bms.local ] }
extract_pairs() {
    awk '
        /ipv4_address/ {
            line = $0
            if (!match(line, /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/)) next
            ip = substr(line, RSTART, RLENGTH)
            if (!match(line, /aliases:[ \t]*\[[^]]*\]/)) next
            a = substr(line, RSTART, RLENGTH)
            sub(/^aliases:[ \t]*\[/, "", a)
            sub(/\][ \t]*$/, "", a)
            n = split(a, arr, ",")
            for (i = 1; i <= n; i++) {
                h = arr[i]
                gsub(/[ \t"'"'"']/, "", h)
                if (h != "") print ip "\t" h
            }
        }
    ' "$COMPOSE_FILE" | sort -u
}

# Current IP declared for a given host in /etc/hosts (empty if absent).
current_ip_for() {
    awk -v h="$1" '
        /^[[:space:]]*#/ { next }
        { for (i = 2; i <= NF; i++) if ($i == h) { print $1; exit } }
    ' /etc/hosts
}

################################################################################
# Build the plan
declare -a OK_LINES=() ADD_PAIRS=() FIX_PAIRS=() FIX_OLD=()

mapfile -t PAIRS < <(extract_pairs)

if [ "${#PAIRS[@]}" -eq 0 ]; then
    echo "${C_DIM}No fixed IP (ipv4_address) declared in ${COMPOSE_FILE}. Nothing to do.${C_RESET}"
    exit 0
fi

for pair in "${PAIRS[@]}"; do
    ip="${pair%%$'\t'*}"
    host="${pair#*$'\t'}"
    current="$(current_ip_for "$host")"
    if [ -z "$current" ]; then
        ADD_PAIRS+=("$ip $host")
    elif [ "$current" = "$ip" ]; then
        OK_LINES+=("$ip $host")
    else
        FIX_PAIRS+=("$ip $host")
        FIX_OLD+=("$current")
    fi
done

################################################################################
# Report
echo
echo "${C_BOLD}Docker hosts sync${C_RESET} ${C_DIM}(${COMPOSE_FILE} -> /etc/hosts)${C_RESET}"
echo

for line in "${OK_LINES[@]:-}"; do
    [ -z "$line" ] && continue
    printf "  ${C_GREEN}[ OK  ]${C_RESET}  %-16s %s\n" ${line}
done
for line in "${ADD_PAIRS[@]:-}"; do
    [ -z "$line" ] && continue
    printf "  ${C_YELLOW}[ ADD ]${C_RESET}  %-16s %s\n" ${line}
done
for i in "${!FIX_PAIRS[@]}"; do
    printf "  ${C_RED}[ FIX ]${C_RESET}  %-16s %s   ${C_DIM}(currently %s)${C_RESET}\n" \
        ${FIX_PAIRS[$i]} "${FIX_OLD[$i]}"
done
echo

TO_APPLY=$(( ${#ADD_PAIRS[@]} + ${#FIX_PAIRS[@]} ))

if [ "$TO_APPLY" -eq 0 ]; then
    echo "${C_GREEN}Everything already in sync.${C_RESET}"
    exit 0
fi

echo "${C_CYAN}${#ADD_PAIRS[@]} to add, ${#FIX_PAIRS[@]} to fix.${C_RESET}"

if [ "$DRY_RUN" -eq 1 ]; then
    echo "${C_DIM}Dry-run: /etc/hosts left untouched.${C_RESET}"
    exit 0
fi

################################################################################
# Confirm
if [ "$ASSUME_YES" -ne 1 ]; then
    printf "%s" "Apply these changes to /etc/hosts (requires sudo)? [y/N] "
    reply=""
    read -r reply < /dev/tty || true
    case "$reply" in
        y|Y|yes|YES) ;;
        *) echo "${C_DIM}Aborted.${C_RESET}"; exit 0 ;;
    esac
fi

################################################################################
# Apply: rebuild /etc/hosts in a temp file, then sudo-copy it back.
tmp="$(mktemp)"
trap 'rm -f "$tmp" "$tmp.new"' EXIT
cp /etc/hosts "$tmp"

# Drop every existing line that references a host we are about to (re)write.
for pair in "${ADD_PAIRS[@]}" "${FIX_PAIRS[@]}"; do
    host="${pair#* }"
    awk -v h="$host" '{
        keep = 1
        if ($0 !~ /^[[:space:]]*#/) { for (i = 2; i <= NF; i++) if ($i == h) { keep = 0; break } }
        if (keep) print
    }' "$tmp" > "$tmp.new" && mv "$tmp.new" "$tmp"
done

# Ensure the file ends with a newline before appending.
[ -s "$tmp" ] && [ -n "$(tail -c1 "$tmp")" ] && printf '\n' >> "$tmp"

# Append the fresh entries, tagged so they are easy to spot.
for pair in "${ADD_PAIRS[@]}" "${FIX_PAIRS[@]}"; do
    ip="${pair%% *}"; host="${pair#* }"
    printf '%s\t%s\t# docker-ips\n' "$ip" "$host" >> "$tmp"
done

echo "${C_DIM}Backing up /etc/hosts -> /etc/hosts.docker-ips.bak${C_RESET}"
sudo cp /etc/hosts /etc/hosts.docker-ips.bak
sudo cp "$tmp" /etc/hosts

echo "${C_GREEN}Done. /etc/hosts updated.${C_RESET}"