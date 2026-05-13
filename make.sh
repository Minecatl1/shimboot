#!/bin/bash
sudo apt update -y
sudo DEBUG=1 ./build_complete.sh cyan compress_img=1 quiet=0 desktop=kde arch=amd64 distro=debian release=trixie || echo "error during build"
echo "cyan bin file made for kde/plasma desktop"