#!/usr/bin/env bash
set -eu

icons="duotone/user-astronaut duotone/address-card duotone/rss duotone/pen-fancy brands/mastodon brands/github brands/linkedin brands/instagram brands/flickr brands/keybase solid/envelope brands/telegram brands/apple duotone/heart duotone/copyright solid/comment-alt-dots solid/key duotone/comments duotone/ruler-combined duotone/door-open duotone/map-marker-smile duotone/shower duotone/moon-stars duotone/usd-circle duotone/flame duotone/people-carry duotone/sun duotone/utensils duotone/phone duotone/envelope-open-text duotone/bullhorn brands/whatsapp duotone/hand-holding-heart"

dest="themes/janwxyz/static/icons"

GITHUB_OWNER="FortAwesome"
GITHUB_REPO="Font-Awesome-Pro"
repo_subdir="https://raw.githubusercontent.com/$GITHUB_OWNER/$GITHUB_REPO/master/svgs"

mkdir -p "${dest}"
cd "${dest}"

for icon in $icons; do
  icon="${icon}.svg"

  curl --header "Authorization: token $GITHUB_API_TOKEN" \
       --header "Accept: application/vnd.github.v3.raw" \
       --fail \
       --remote-name -J \
       --location "${repo_subdir}/${icon}"
done