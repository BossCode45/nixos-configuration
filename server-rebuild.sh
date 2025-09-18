#!/usr/bin/env bash

nixos-rebuild switch --use-remote-sudo --target-host 172.105.172.191 --flake ".#nixnode" -j $(nproc)
