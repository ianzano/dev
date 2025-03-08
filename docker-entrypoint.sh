#!/bin/bash

DATA_DIR="/data"

if [ ! $(getent group $GROUP) ]; then
    groupadd $GROUP
    echo "%$GROUP ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

if [ ! $(getent passwd $USER) ]; then
    useradd -m -g "$GROUP" -d "/home/$USER" "$USER"
    echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

mkdir -p ~/.ssh
ln -s /run/secrets/id_ed25519 ~/.ssh
touch ~/.ssh/known_hosts
ssh-keyscan github.com >> ~/.ssh/known_hosts

for REPO in $REPOS; do
    git config --global --add safe.directory "$DATA_DIR/$REPO"
    [ -d "$DATA_DIR/$REPO" ] && git -c "core.sshCommand=ssh -i /run/secrets/id_ed25519" -C "$REPO" pull || git clone -c "core.sshCommand=ssh -i /run/secrets/id_ed25519" "git@github.com:dianaphp/$REPO.git"
    [ -f "$DATA_DIR/$REPO/composer.json" ] && composer install --working-dir="$DATA_DIR/$REPO"
    [ -f "$DATA_DIR/$REPO/package.json" ] && npm install --prefix "$DATA_DIR/$REPO"
done

chown -R $USER:$GROUP "$DATA_DIR"
chown $USER:$GROUP $COMPOSER_HOME

npm run --prefix "$DATA_DIR/$SERVE" dev