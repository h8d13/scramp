#!/usr/bin/env bash
# usage: ./buildit.sh [dir...]   (stamps dir/*.in into $outdir, default: src)
# output goes to $BUILDDIR/<name>-<version>/ (default BUILDDIR: .)
set -u
shopt -s nullglob

BUILDDIR=${BUILDDIR:-.}

declare -A subst=(
	[prefix]=/usr
	[sysconfdir]=/etc
	[PACKAGE_NAME]=buildit
	[PACKAGE_VERSION]=0.0.1
)
outdir=$BUILDDIR/${subst[PACKAGE_NAME]}-${subst[PACKAGE_VERSION]}

(( $# )) || set -- src

# stamp one .in file into its output; returns non-zero on error
stamp() {
	local src=$1 dst=$outdir/${1%.in} content= key
	# only guard is that the inputs exists
	if [[ ! -r $src ]]; then
		printf '%s: cannot read\n' "$src" >&2; return 1
	fi
	# read -d '' keeps trailing newlines
	IFS= read -r -d '' content <"$src"
	for key in "${!subst[@]}"; do
		content=${content//"@$key@"/"${subst[$key]}"}
	done
	# warn if something is missing from declare here on top
	if [[ $content =~ @[A-Za-z_][A-Za-z0-9_]*@ ]]; then
		printf '%s: unsubstituted %s\n' "$src" "${BASH_REMATCH[0]}" >&2; return 1
	fi
	printf '%s' "$content" >"$dst" || return
	# if a *.in file contains a shebang, we mark it's exec bit here.
	# only stamped scripts are executable ($outdir is fresh, so always needed)
	if [[ $content == '#!'* ]]; then
		chmod +x "$dst" || return
	fi
}

# fresh $outdir per run so no stale files or modes carry over
rm -rf "$outdir" || exit

for dir in "$@"; do
	# output mirrors $dir, so it must stay inside $outdir
	if [[ $dir == /* || /$dir/ == */../* ]]; then
		printf '%s: use a relative dir inside the project\n' "$dir" >&2; exit 1
	fi
	mkdir -p "$outdir/$dir" || exit
	for src in "$dir"/*.in; do
		stamp "$src" || exit
	done
done
printf '%s\n' "$outdir"
