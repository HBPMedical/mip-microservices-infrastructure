#!/usr/bin/env bash

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value

count=$(git status --porcelain | wc -l)

# shellcheck disable=SC2086
if test $count -gt 0; then
  git status
  echo "Not all files have been committed in Git. Release aborted"
  exit 1
fi

select_part() {
  local choice=$1
  case "$choice" in
      "Patch release")
          bumpversion patch
          ;;
      "Minor release")
          bumpversion minor
          ;;
      "Major release")
          bumpversion major
          ;;
      *)
          read -r -p "Version > " version
          bumpversion --new-version="$version" all
          ;;
  esac
}

git pull --tags
# Look for a version tag in Git. If not found, ask the user to provide one
# shellcheck disable=SC2046
[[ $(git tag --points-at HEAD | wc -l) == 1 ]] || (
  latest_version=$(bumpversion --dry-run --list patch | grep current_version | sed -r s,"^.*=",, || echo '0.0.1')
  echo
  echo "Current commit has not been tagged with a version. Latest known version is $latest_version."
  echo
  echo 'What do you want to release?'
  PS3='Select the version increment> '
  options=("Patch release" "Minor release" "Major release" "Release with a custom version")
  select choice in "${options[@]}";
  do
    select_part "$choice"
    break
  done
  updated_version=$(bumpversion --dry-run --list patch | grep current_version | sed -r s,"^.*=",,)
  read -r -p "Release version $updated_version? [y/N] > " ok
  if [[ "$ok" != "y" ]]; then
    echo "Release aborted"
    exit 1
  fi
)

updated_version=$(bumpversion --dry-run --list patch | grep current_version | sed -r s,"^.*=",,)

git push
git push --tags

# Notify on slack
# shellcheck disable=SC1091
source ./common/lib/slack-helper.sh
sed "s/USER/${USER^}/" slack.json | sed "s/VERSION/$updated_version/" | post-to-slack
