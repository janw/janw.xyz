#!/usr/bin/env bash
set -eu

icons="light/user-astronaut light/address-card light/rss light/pen-fancy brands/mastodon brands/github brands/linkedin brands/instagram brands/flickr brands/keybase solid/envelope brands/telegram brands/apple light/heart light/copyright solid/comment-alt-dots solid/key light/comments light/ruler-combined light/door-open light/map-marker-smile light/shower light/moon-stars light/usd-circle light/flame light/people-carry light/sun light/utensils light/phone light/envelope-open-text light/bullhorn brands/whatsapp light/hand-holding-heart"

dest="themes/janwxyz/static/icons"

GITHUB_OWNER="FortAwesome"
GITHUB_REPO="Font-Awesome-Pro"
repo_subdir="https://raw.githubusercontent.com/$GITHUB_OWNER/$GITHUB_REPO/master/advanced-options/raw-svg"

mkdir -p "${dest}"
cd "${dest}"

for icon in $icons; do
  icon="${icon}.svg"

  curl --header "Authorization: token $GITHUB_API_TOKEN" \
       --header "Accept: application/vnd.github.v3.raw" \
       --remote-name -J \
       --location "${repo_subdir}/${icon}"
done