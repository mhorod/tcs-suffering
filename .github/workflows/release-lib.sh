# Adapted by @tfkls from his work at https://github.com/tfkls/sio2-contest-template
# This is free and unencumbered software released in the public domain. See <unlicense.org> for more details.
# vi:ts=2:sw=2:noet:

# THIS MUST BE SOURCED
# shellcheck shell=bash
load_release() {
	rm -rf ./_build/
	mkdir ./_build/
	mkdir ./_build/results
	touch ./_build/status
	cat >./_build/base-release-notes.md <<EOF
PDF notes generated from sources on push by a github action.
Last update: 0000-00-00 00:00:00 +0000 (commit 00000000) <!-- DO NOT EDIT THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING!!! -->

Currently available PDFs:

<!-- BEGIN_STATUS_TABLE -->
| Name | Files | Build info |
|------|-------|------------|
<!-- END_STATUS_TABLE -->
EOF

	if ! gh release view pdfs >/dev/null; then
		gh release create pdfs --title 'PDFs' --notes-file ./_build/base-release-notes.md
	fi

	gh release view pdfs --json body --jq '.body' >./_build/release-notes.md
	grep '^Last update:' ./_build/release-notes.md | cut -c 14-38 >./_build/release-time
	grep '^Last update:' ./_build/release-notes.md | sed -Ee 's/.*?\(commit ([0-9a-f]+)\)/\1/' | tr -cd '0-9a-f\n' >./_build/release-commit
	RELEASE_TIME=$(cat ./_build/release-time)
	RELEASE_COMMIT=$(cat ./_build/release-commit)
	if echo "$RELEASE_TIME" | grep -qv '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9] [+\-][0-9][0-9][0-9][0-9]$'; then
		RELEASE_TIME="0000-00-00 00:00:00 +0000"
	fi

	if [ "$RELEASE_TIME" = "0000-00-00 00:00:00 +0000" ]; then
		git fetch --unshallow
	else
		git fetch --shallow-since "$RELEASE_TIME" || git fetch --unshallow
	fi

	if [ "$RELEASE_TIME" = "0000-00-00 00:00:00 +0000" ]; then
		git log --pretty=format:%s | tee ./_build/git-logs
	else
		git log "$RELEASE_COMMIT..HEAD" --pretty=format:%s | tee ./_build/git-logs
	fi

	sed -ne '/BEGIN_STATUS_TABLE/,/END_STATUS_TABLE/p' ./_build/release-notes.md | head -n -1 | tail -n +4 >./_build/release-notes.table

	rm -f ./_build/potential_update
	touch ./_build/potential_update
	for dir in *; do
		[ -d "$dir" ] && [ -f "$dir"/main.tex ] && echo "$dir" >>./_build/potential_update
	done

	rm -f ./_build/update
	if ! [ -f './.forced-rebuild' ]; then
		rm -f ./_build/git-logs-rebuild
		touch ./_build/git-logs-rebuild
		grep -ohEi '!rebuild-([a-zA-Z0-9-]*|\*)' ./_build/git-logs >>./_build/git-logs-rebuild || true
		while IFS= read -r word; do
			case "$word" in
			'!rebuild-*')
				gh release edit pdfs --notes-file ./_build/base-release-notes.md
				touch './.forced-rebuild'
				load_release && exit "$?" || exit "$?"
				;;
			'!rebuild-'*)
				dir="${word#!rebuild-}"
				grep -q "^${dir}$" ./_build/update 2>/dev/null && continue
				grep -q "^${dir}$" ./_build/potential_update 2>/dev/null || continue
				echo "$dir" >>./_build/update
				;;
			*)
				# Unreachable, but we don't care
				true
				;;
			esac
		done <./_build/git-logs-rebuild
	fi

	while IFS= read -r dir; do
		[ -z "$dir" ] && continue
		grep -q "^${dir}$" ./_build/update 2>/dev/null && continue
		if [ "$RELEASE_COMMIT" = "00000000" ]; then
			echo "$dir" >>./_build/update
		elif [ "$RELEASE_COMMIT" = "$(git rev-parse --short HEAD)" ]; then
			true
		elif grep "^| ${dir} |" ./_build/release-notes.table; then
			git diff --quiet "$RELEASE_COMMIT" HEAD ./"$dir" || echo "$dir" >>./_build/update
		else
			echo "$dir" >>./_build/update
		fi
	done <./_build/potential_update

	[ -f "./_build/update" ] && echo "update=true" >>"$GITHUB_OUTPUT" || echo "update=false" >>"$GITHUB_OUTPUT"
	touch ./_build/update
}

save_release() {
	mv ./_build/release-notes.md ./_build/old-release-notes.md
	cat >./_build/release-notes.md <<EOF
PDF notes generated from sources on push by a github action.
Last update: $(git log HEAD^..HEAD --pretty=format:%ai) (commit $(git rev-parse --short HEAD)) <!-- DO NOT EDIT THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING!!! -->

Currently available PDFs:

<!-- BEGIN_STATUS_TABLE -->
| Name | Files | Build info |
|------|-------|------------|
EOF
	RELEASE_TIME=$(cat ./_build/release-time)
	RELEASE_COMMIT=$(cat ./_build/release-commit)
	gh release view pdfs --json assets --jq '.assets | map(.name) | .[]' >./_build/old-assets

	rm -f ./_build/generated
	sort ./_build/potential_update >./_build/generated

	while IFS= read -r dir; do
		[ -z "$dir" ] && continue
		if line=$(grep "^| ${dir} |" ./_build/release-notes.table); then
			BUILD=$(echo "$line" | head -n 1 | cut -d '|' -f 3 | xargs)
			STATUS=$(echo "$line" | head -n 1 | cut -d '|' -f 4 | xargs)
		else
			BUILD="Unknown"
			STATUS="Last build: Unknown (never built)"
		fi
		if grep -q "^${dir}\$" "./_build/update"; then
			STATUS=$(grep "^${dir}:" ./_build/status | cut -d ':' -f 2)
			STATUS="Last build: $STATUS (commit $(git rev-parse --short HEAD))<br>Warnings:"

			BUILD="[Build&nbsp;logs](https://github.com/$GH_REPO/releases/download/pdfs/${dir}.log)"
			gh release upload pdfs "./_build/results/${dir}.log" --clobber

			if [ -f "./_build/results/${dir}.pdf" ]; then
				BUILD="$BUILD<br>[PDF&nbsp;file](https://github.com/$GH_REPO/releases/download/pdfs/${dir}.pdf)"
				gh release upload pdfs "./_build/results/${dir}.pdf" --clobber
			else
				grep -q "^${dir}.pdf$" ./_build/old-assets && gh release delete-asset pdfs "${dir}.pdf"
				STATUS="$STATUS<br>\`No PDF file generated.\`"
			fi
		fi

		echo "| ${dir} | ${BUILD} | ${STATUS} |" >>./_build/release-notes.md
	done <./_build/generated
	echo '<!-- END_STATUS_TABLE -->' >>./_build/release-notes.md

	gh release edit pdfs --latest --notes-file ./_build/release-notes.md
}
