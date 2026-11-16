### ——————————————————————————————————————————————————————————————————
### —— Project Statistics
### ——————————————————————————————————————————————————————————————————
#
# Standalone report, any kind of project: POSIX sh + awk only.
# Optional tools are used when available: git, composer.
#
#   make stats                      Full report
#   make stats STATS_TOP=10         Show 10 largest files
#   make stats STATS_SKIP=composer  Skip slow network checks (composer)
#   STATS_EXCLUDE := assets/plugins Exclude paths matching this regex (third-party code)
#   NO_COLOR=1 make stats           Disable colors

STATS_TOP  ?= 5
STATS_SKIP ?=
STATS_EXCLUDE ?=

define _STATS_SH
set -u
TOP="${STATS_TOP:-5}"
WIDTH=68

#====================================================================#
# Colors (disabled on NO_COLOR, enabled on terminals & CI)
if [ -z "${NO_COLOR:-}" ] && { [ -t 1 ] || [ -n "${CI:-}" ]; }; then
    E=$(printf '\033')
    B="$E[1m"; D="$E[2m"; R="$E[0m"; CY="$E[36m"; GR="$E[32m"; YE="$E[33m"; RE="$E[31m"; MA="$E[35m"
else
    B=""; D=""; R=""; CY=""; GR=""; YE=""; RE=""; MA=""
fi

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT INT TERM

#====================================================================#
# Layout helpers
repeat() { printf "%$1s" "" | sed "s/ /$2/g"; }
title() { printf '%s╭─%s %s%s%s %s%s\n' "$D" "$R" "$B$CY" "$1" "$R" "$D$(repeat $((WIDTH - ${#1} - 4)) ─)" "$R"; }
section() { printf '%s├─%s %s%s%s %s%s\n' "$D" "$R" "$B" "$1" "$R" "$D$(repeat $((WIDTH - ${#1} - 4)) ─)" "$R"; }
row() { printf '%s│%s  %s\n' "$D" "$R" "$1"; }
footer() { printf '%s╰%s%s\n' "$D" "$(repeat $((WIDTH - 1)) ─)" "$R"; }
json_value() { sed -n "s/^ *\"$1\": *\"\([^\"]*\)\".*/\1/p" "$2" 2>/dev/null | head -n 1; }

#====================================================================#
# Project name
NAME=$(json_value name composer.json)
[ -n "$NAME" ] || NAME=$(json_value name package.json)
[ -n "$NAME" ] || NAME=$(basename "$PWD")
title "$NAME"

#====================================================================#
# Git
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    [ "$BRANCH" = "HEAD" ] && BRANCH="${CI_COMMIT_REF_NAME:-detached}"
    LAST=$(git log -1 --format='%h · %cr' 2>/dev/null)
    INFO="$MA⎇ $BRANCH$R $D·$R $LAST"
    if [ "$(git rev-parse --is-shallow-repository 2>/dev/null)" = "false" ]; then
        COMMITS=$(git rev-list --count HEAD 2>/dev/null)
        AUTHORS=$(git shortlog -sn HEAD 2>/dev/null | wc -l | tr -d ' ')
        INFO="$INFO $D·$R $COMMITS commits $D·$R $AUTHORS contributors"
    fi
    DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    [ "$DIRTY" -gt 0 ] && INFO="$INFO $D·$R $YE$DIRTY uncommitted$R"
    row "$INFO"
    git ls-files -z --cached --others --exclude-standard > "$TMP/all" 2>/dev/null
else
    find . -type f ! -path '*/.git/*' -print0 > "$TMP/all"
fi

#====================================================================#
# Source files: known text types only, dependencies & generated files excluded
LANG_AWK='
function lang(path,    base, ext) {
    base = path; sub(/.*\//, "", base)
    if (path ~ /(^|\/)(vendor|node_modules|var|build|dist|\.git)\//) return ""
    if (base ~ /\.min\.(js|css)$/ || base ~ /^(package-lock\.json|composer\.lock|yarn\.lock)$/) return ""
    if (base ~ /^(Dockerfile|Containerfile)/ || base ~ /\.dockerfile$/) return "Docker"
    if (base ~ /^(Makefile|GNUmakefile)$/ || base ~ /\.mk$/) return "Make"
    sub(/\.dist$/, "", base)
    ext = base; if (!sub(/.*\./, "", ext)) return ""
    if (ext == "php") return "PHP"
    if (ext == "twig") return "Twig"
    if (ext ~ /^(js|mjs|cjs|jsx)$/) return "JavaScript"
    if (ext ~ /^(ts|tsx)$/) return "TypeScript"
    if (ext == "vue") return "Vue"
    if (ext ~ /^(css|scss|sass|less)$/) return "Styles"
    if (ext ~ /^(html|htm)$/) return "HTML"
    if (ext ~ /^(yml|yaml|neon)$/) return "YAML"
    if (ext == "json") return "JSON"
    if (ext ~ /^(xml|xsd|xlf|xliff)$/) return "XML"
    if (ext ~ /^(md|markdown|rst)$/) return "Docs"
    if (ext ~ /^(sh|bash|zsh)$/) return "Shell"
    if (ext == "py") return "Python"
    if (ext == "sql") return "SQL"
    if (ext ~ /^(ini|env|conf|toml)$/) return "Config"
    return ""
}'
tr '\0' '\n' < "$TMP/all" | awk -v excl="${STATS_EXCLUDE:-}" "$LANG_AWK"'
    (excl == "" || $0 !~ excl) && lang($0) != ""
' > "$TMP/files"
tr '\n' '\0' < "$TMP/files" | xargs -0 awk '
    FNR == 1 && NR > 1 { print n "\t" f }
    FNR == 1 { f = FILENAME; n = 0 }
    { n++ }
    END { if (NR) print n "\t" f }
' 2>/dev/null > "$TMP/sizes"

section "Sources"
awk -F '\t' -v cy="$CY" -v dim="$D" -v rst="$R" -v bold="$B" "$LANG_AWK"'
    function fmt(n,    s) { s = sprintf("%d", n); while (s ~ /[0-9][0-9][0-9][0-9]/) sub(/[0-9][0-9][0-9]($| )/, " &", s); return s }
    { l = lang($2); files[l]++; lines[l] += $1; total += $1; count++ }
    END {
        for (l in lines) printf "%d\t%s\t%d\n", lines[l], l, files[l] | "sort -rn > \"'"$TMP"'/langs\""
        close("sort -rn > \"'"$TMP"'/langs\"")
        while ((getline row < "'"$TMP"'/langs") > 0) {
            split(row, c, "\t"); pct = total ? 100 * c[1] / total : 0
            full = int(pct / 5 + 0.5); bar = cy; for (i = 0; i < 20; i++) bar = bar (i == full ? dim : "") (i < full ? "█" : "░")
            printf "%-11s %6s files %9s lines  %s%s %3d%%\n", c[2], fmt(c[3]), fmt(c[1]), bar, rst, pct
        }
        printf "%s%-11s %6s files %9s lines%s\n", bold, "Total", fmt(count), fmt(total), rst
    }' "$TMP/sizes" > "$TMP/langs.out"
while IFS= read -r LINE; do row "$LINE"; done < "$TMP/langs.out"
MARKS=$(tr '\n' '\0' < "$TMP/files" | xargs -0 grep -hE 'TO''DO|FIX''ME' 2>/dev/null | wc -l | tr -d ' ')
[ "$MARKS" -gt 0 ] && row "$D$MARKS TO""DO/FIX""ME markers$R"

#====================================================================#
# Largest code files (data & docs excluded)
section "Largest files"
awk -F '\t' "$LANG_AWK"' lang($2) !~ /^(JSON|YAML|XML|Docs)$/' "$TMP/sizes" | sort -rn | head -n "$TOP" \
    | while IFS="$(printf '\t')" read -r N F; do row "$(printf '%6s' "$N")  $D$F$R"; done

#====================================================================#
# PHP structures (only when PHP sources are found)
grep '\.php$' "$TMP/files" > "$TMP/php" || true
if [ -s "$TMP/php" ]; then
    section "PHP"
    tr '\n' '\0' < "$TMP/php" | xargs -0 awk '
        /^[ \t]*((abstract|final|readonly)[ \t]+)*class[ \t]+[A-Za-z_]/ { c++ }
        /^[ \t]*interface[ \t]+[A-Za-z_]/ { i++ }
        /^[ \t]*trait[ \t]+[A-Za-z_]/ { t++ }
        /^[ \t]*enum[ \t]+[A-Za-z_]/ { e++ }
        /function[ \t]+&?[A-Za-z_]/ { f++ }
        END { print c + 0, i + 0, t + 0, e + 0, f + 0 }
    ' 2>/dev/null | awk '{ c += $1; i += $2; t += $3; e += $4; f += $5 }
        END { printf "%d classes · %d interfaces · %d traits · %d enums · %d functions\n", c, i, t, e, f }' > "$TMP/php.out"
    TESTS=$(grep -c 'Test\.php$' "$TMP/php")
    row "$(cat "$TMP/php.out") $D·$R $TESTS test classes"
fi

#====================================================================#
# Composer dependencies, outdated packages & security
if [ -f composer.json ] && command -v composer >/dev/null 2>&1 && [ "${STATS_SKIP#*composer}" = "${STATS_SKIP}" ]; then
    section "Composer"
    composer outdated --direct --format=json --no-interaction --no-ansi > "$TMP/outdated" 2>/dev/null
    composer audit --format=json --abandoned=report --no-interaction --no-ansi > "$TMP/audit" 2>/dev/null
    DIRECT=$(composer show --direct --name-only --no-interaction --no-ansi 2>/dev/null | grep -c /)
    awk -v top="$TOP" -v red="$RE" -v yel="$YE" -v dim="$D" -v rst="$R" -v grn="$GR" -v direct="$DIRECT" '
        function value(line) { sub(/^[^:]*: *"?/, "", line); sub(/"?,? *$/, "", line); return line }
        /"name":/ { name = value($0) }
        /"version":/ { ver = value($0) }
        /"latest":/ { last = value($0) }
        /"latest-status":/ {
            status = value($0)
            if (status == "up-to-date") next
            level = (status == "update-possible") ? "major" : "minor"
            n++; count[level]++
            out[n] = sprintf("%s%-5s%s %-38s %12s → %s", level == "major" ? red : yel, level, rst, name, ver, last)
            rank[n] = (level == "major") ? 0 : 1
        }
        END {
            if (!n) { printf "%d direct · %s✔ all up to date%s\n", direct, grn, rst; exit }
            printf "%d direct · %d outdated %s(%d major, %d minor/patch)%s\n", direct, n, dim, count["major"], count["minor"], rst
            shown = 0
            for (r = 0; r <= 1; r++) for (i = 1; i <= n; i++) if (rank[i] == r && shown < top) { print out[i]; shown++ }
            if (n > shown) printf "%s… and %d more%s\n", dim, n - shown, rst
        }
    ' "$TMP/outdated" | while IFS= read -r LINE; do row "$LINE"; done
    awk -v red="$RE" -v yel="$YE" -v dim="$D" -v rst="$R" -v grn="$GR" -v bold="$B" '
        function value(line) { sub(/^[^:]*: *"?/, "", line); sub(/"?,? *$/, "", line); return line }
        function flush(    color, label) {
            if (pkg != "") {
                color = (sev ~ /^(critical|high)$/) ? red : (sev == "medium" ? yel : dim)
                label = (cve != "") ? cve : title
                gsub(/\\"/, "\"", label); if (length(label) > 50) label = substr(label, 1, 49) "…"
                adv[++a] = sprintf("%s✘%s %s%s%s %s%s%s%s%s", red, rst, bold, pkg, rst, color, sev == "null" ? "" : sev " ", rst, dim, label rst)
            }
            pkg = sev = cve = title = ""
        }
        /"advisoryId":/ { flush() }
        /"packageName":/ { pkg = value($0) }
        /"cve":/ { cve = value($0); if (cve == "null") cve = "" }
        /"title":/ { title = value($0) }
        /"severity":/ { sev = value($0) }
        /^    "abandoned": *\{/ { flush(); inab = 1; next }
        inab && /^    \}/ { inab = 0 }
        inab && /":/ { split($0, p, "\""); repl = value($0); ab[++b] = sprintf("%s✘%s %s%s%s %s%s%s", yel, rst, bold, p[2], rst, dim, repl == "null" ? "no replacement" : "→ " repl, rst) }
        END {
            flush()
            if (a) { print "Security   " a " advisories"; for (i = 1; i <= a; i++) print "           " adv[i] }
            else print "Security   " grn "✔ no known vulnerability" rst
            if (b) { print "Abandoned  " b " packages"; for (i = 1; i <= b; i++) print "           " ab[i] }
            else print "Abandoned  " grn "✔ none" rst
        }
    ' "$TMP/audit" | while IFS= read -r LINE; do row "$LINE"; done
fi

footer
endef

stats: export STATS_SH := $(value _STATS_SH)
stats: 	## Show Project Statistics (sources, git, composer & security)
	@STATS_TOP="$(STATS_TOP)" STATS_SKIP="$(STATS_SKIP)" STATS_EXCLUDE="$(STATS_EXCLUDE)" sh -c "$$STATS_SH"
