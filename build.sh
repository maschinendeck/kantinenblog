#!/bin/bash

set -ev


echo "Config"

# Get the deploy key by using Travis's stored variables to decrypt deploy_key.enc
# https://gist.github.com/domenic/ec8b0fc8ab45f39403dd
ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in deploy_key.enc -out deploy_key -d
chmod 600 deploy_key
eval `ssh-agent -s`
ssh-add deploy_key

git config --global user.name "Travis CI"
git config --global user.email "ci@maschinendeck.org"

git clone git@github.com:maschinendeck/kantinenblog.git




echo "Build"


# Final site is in kantinenblog/gh-pages
cd kantinenblog
git checkout gh-pages

# always build full site
rm -rf *

cd ..


# Build site

hugo -b http://www.maschinendeck.org/kantinenblog// -d gh-pages || true

ls -al
ls -al gh-pages

rsync -av gh-pages/* kantinenblog

git add --all .
git commit -m "Built gh-pages"
git push origin gh-pages


echo "Done"
