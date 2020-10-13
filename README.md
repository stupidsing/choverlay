# What is this?

choverlay - create an overlay fs of current directory immediately so you can do naughty experiments.

choverlayx - restore to original directory.

use flag -s if you want to create overlay using superuser mount.

a.k.a. copy-on-write file system.

# Prerequisites

`sudo apt install fuse_overlayfs`

# Funny things you can do

like running containers yourself by doing many overlays:

```bash
sudo apt install debootstrap schroot

. choverlay.sh

C=openjdk:14 &&
docker pull ${C} &&

cd $(mktemp -d) &&
docker save ${C} | tar xf - &&
CFG=$(cat manifest.json | jq -r '.[0].Config') &&
TARS=$(cat manifest.json | jq -r '.[0].Layers | join(" ")' | xargs readlink -f) &&
ENV=$(cat ${CFG} | jq -r '.config.Env | join(" ")') &&

cd $(mktemp -d) &&
for TAR in ${TARS}; do
  choverlay -s && pwd && sudo tar xf ${TAR}
done &&

## how to load ${ENV}???
sudo chroot . /bin/sh -c "LD_LIBRARY_PATH=./usr/java/openjdk-14/lib javac --version" &&

for TAR in ${TARS}; do
  choverlayx -s
done
```
