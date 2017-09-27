#!/bin/bash

if [[ -z $1 ]] ; then
  >&2 echo "Missing argument!"
  echo "Usage:"
  echo "  test-remove.sh <tag>"
  exit 1
else
	TAG="$1"
fi

auth_str=$(cat ~/.docker/config.json | grep auth | awk '{ print substr($2, 2, length($2) - 2) }' | base64 -d)

dh_login=$(echo $auth_str | awk -F ':' '{ print $1 }')
dh_pass=$(echo $auth_str | awk -F ':' '{ print $2 }')
dh_token=$(curl -s -H "Content-Type: application/json" -X POST -d "{\"username\": \"$dh_login\", \"password\": \"$dh_pass\"}" https://hub.docker.com/v2/users/login/ | jq -r .token)

function remove_tag {
	curl -s -H "Authorization: JWT ${dh_token}" -X DELETE https://hub.docker.com/v2/repositories/$1/
}

docker_images="
  magneticio/vamp
  magneticio/vamp-ee
  magneticio/vamp-gateway-agent
  magneticio/vamp-workflow-agent
  magneticio/vamp-docker
  magneticio/vamp-runner
"

# Check that we have our images available
for i in $docker_images; do
  declare -i is_custom=$(docker images --format "{{.Repository}}:{{.Tag}}" "$i:*" | grep -Ei ':[a-z].+' | wc -l)
  if [ $is_custom -gt 0 ]; then
    for j in $(docker images --format "{{.Repository}}:{{.Tag}}" "$i:*" | grep -E ":$TAG"); do
      if [ "$TAG" != "master" ]; then
        echo "${green}Found matching image: ${j}${reset}"
        remove_tag "$(echo $j | sed -e "s/:/\/tags\//")"
      fi
    done
  fi
done
