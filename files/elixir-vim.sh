#!/bin/sh
DIR=$(dirname ~/.elixir-vim/.)
# shellcheck disable=SC1090
. "$DIR/.config"

SRC_DIR=$(dirname "$HOST_SOURCE_DIR"/.)
mkdir -p "$SRC_DIR"

docker run -it --mount src="$DIR",target=/elixir-vim,type=bind --mount src="$SRC_DIR,target=/home/$USERNAME/src,type=bind" --hostname=elixir-vim --rm elixir-vim:latest
