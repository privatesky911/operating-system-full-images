#!/bin/bash
#

cp -rvf ../operating-system/output/images/haos_odroid-m1s-18.3.img.xz input/

make build IMAGE=haos_odroid-m1s-18.3.img.xz
