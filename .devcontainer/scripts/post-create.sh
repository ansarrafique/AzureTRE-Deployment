#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
# Uncomment this line to see each command for debugging (careful: this will show secrets!)
# set -o xtrace

# show the AzureTRE OSS folder inside the workspace one
rm -fr AzureTRE || true
ln -s "${AZURETRE_HOME}" AzureTRE

cp ~/AzureTRE/config.sample.yaml .

# docker socket fixup
sudo bash AzureTRE/devops/scripts/set_docker_sock_permission.sh

# --- v0.27.0 PORTER CACHE FIX ---
# PR #4827 uses --cache-to/--cache-from flags. These require a 'docker-container' driver.
# Since we are inside a dev container, we must create a local builder instance.
echo "Initializing Buildx tre-builder for Porter compatibility..."
if ! docker buildx ls | grep -q "tre-builder"; then
    docker buildx create --name tre-builder --driver docker-container --use
    docker buildx inspect --bootstrap
else
    docker buildx use tre-builder
fi
