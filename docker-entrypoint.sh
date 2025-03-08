#!/bin/sh

DATA_DIR="/data"

if [ ! $(getent group $GROUP) ]; then
    groupadd $GROUP
    echo "%$GROUP ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

if [ ! $(getent passwd $USER) ]; then
    useradd -m -g "$GROUP" -d "/home/$USER" "$USER"
    echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

chown -R $USER:$GROUP "$DATA_DIR"
chown $USER:$GROUP $COMPOSER_HOME
su $USER

for REPO in $REPOS; do 
    git config --global --add safe.directory "$DATA_DIR/$REPO"
    [ -d "$DATA_DIR/$REPO" ] && git -C "$REPO" pull || git clone "https://github.com/dianaphp/$REPO.git"
done

for REPO in $REPOS; do 
    composer install --working-dir="$DATA_DIR/$REPO"
done

php -S 0.0.0.0:8000 "$DATA_DIR/$SERVE"