#!/bin/sh

DATA_DIR="/data"

if [ $INIT == 'yes' ]; then
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
      [ -f "$DATA_DIR/$REPO/composer.json" ] && composer install --working-dir="$DATA_DIR/$REPO"
      [ -f "$DATA_DIR/$REPO/package.json" ] && npm install --prefix "$DATA_DIR/$REPO"
  done

  INIT=no
fi

npm run --prefix "$DATA_DIR/$SERVE" dev -- --host
