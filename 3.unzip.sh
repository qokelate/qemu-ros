#!/bin/bash

set -ex

cd "$(dirname "$0")"
cd "$(realpath "$PWD")"

unzip kvm-ros.zip
mv -fv ros/ros.qcow2 ./
rm -rf ros

exit
