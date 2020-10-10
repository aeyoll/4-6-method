#!/usr/bin/env sh

# abort on errors
set -e

# build
yarn run build

# navigate into the build output directory
cd dist

# push to github
git init
git add -A
git commit -m 'deploy'

git push -f git@github.com:aeyoll/4-6-method.git master:gh-pages