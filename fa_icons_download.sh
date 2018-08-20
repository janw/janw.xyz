#!/usr/bin/env bash
set -e

icons="light/user-astronaut light/address-card light/rss light/pen-fancy brands/mastodon brands/github brands/instagram brands/flickr brands/keybase light/envelope brands/telegram brands/apple light/heart light/copyright"

dest="themes/janwxyz/static/icons"

GITHUB_API_TOKEN="###SECRET###"
GITHUB_OWNER="FortAwesome"
GITHUB_REPO="Font-Awesome-Pro"
repo_subdir="https://raw.githubusercontent.com/$GITHUB_OWNER/$GITHUB_REPO/master/advanced-options/raw-svg"

mkdir -p "${dest}"
cd "${dest}"

for icon in $icons; do
  icon="${icon}.svg"

  curl --header "Authorization: token $GITHUB_API_TOKEN" \
       --header "Accept: application/vnd.github.v3.raw" \
       --remote-name \
       --location "${repo_subdir}/${icon}"
done