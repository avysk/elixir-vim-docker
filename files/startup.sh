#!/bin/sh

set -eu

ELIXIR_VIM_VERSION=1

if [ -e /elixir-vim/not-configured ]; then cat <<EOF
Elixir-vim is not yet configured. To configure elixir-vim please run the following command on your host machine:

mkdir -p ~/.elixir-vim && docker run -it --mount src="\$(dirname ~/.elixir-vim/.)",target=/elixir-vim,type=bind --rm elixir-vim:latest

EOF
exit 0
fi

### Default values

# We don't want expansion inside the container
# shellcheck disable=SC2088
HOST_SOURCE_DIR="~/elixir-vim-src"

USERNAME=$(basename "$HOME")

reconfigure() {

        printf "The directory where you want to keep source files of your projects [%s]: " "$HOST_SOURCE_DIR"
        read -r answer

        if [ "x$answer" != "x" ]
        then
                HOST_SOURCE_DIR="$answer"
        fi

        echo "Got $HOST_SOURCE_DIR"

        cat > /elixir-vim/.config <<EOF
VERSION=$ELIXIR_VIM_VERSION
HOST_SOURCE_DIR=$HOST_SOURCE_DIR
USERNAME=$USERNAME
EOF
        cp /etc/elixir-vim/elixir-vim.sh /elixir-vim
        chmod +x /elixir-vim/elixir-vim.sh
        echo "Please now run the image using ~/.elixir-vim/elixir-vim.sh script"
        exit 0
}

check_config() {
        # shellcheck disable=SC1091
        . /elixir-vim/.config
        if [ -z "$VERSION" ]; then reconfigure; fi
        if [ $ELIXIR_VIM_VERSION -eq "$VERSION" ]; then return; fi
        if [ $ELIXIR_VIM_VERSION -lt "$VERSION" ]; then
                echo "Found configuration for elixir-vim version $VERSION; however, you are running $ELIXIR_VIM_VERSION. Exiting."
                exit 1
        fi
        if [ $ELIXIR_VIM_VERSION -gt "$VERSION" ]; then
                echo "Found configuration for elixir-vim version $VERSION; however, you are running $ELIXIR_VIM_VERSION. Reconfiguration needed."
        fi
        reconfigure
}


if [ -e /elixir-vim/.config ]; then
        check_config
else
        reconfigure
fi

mkdir -p /elixir-vim/.vim/undo

/usr/bin/tmux
