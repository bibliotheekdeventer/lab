#! /usr/bin/env bash

nix-shell -p nixos-generators --run "nixos-generate -f iso -c configuration.nix -I nixpkgs=/home/aengelen/nixpkgs-inkscape" 
