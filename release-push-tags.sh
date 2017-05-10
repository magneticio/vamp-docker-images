echo "${green}Pushing git tags${reset}"
${root}/release-tag.sh "$TAG" push
git push --tags
