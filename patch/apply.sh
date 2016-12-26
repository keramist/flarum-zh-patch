#!/bin/sh
if [ ! -z $1 ]; then
	cd $1
fi
vendor_dir=`pwd`
flarum_dir=$vendor_dir/flarum
if [ ! -z $1 ]; then
	cd -
fi

cd `dirname $0`
patch_dir=`pwd`

for patch in `ls $patch_dir`; do
	if [[ ! -z `echo $patch | grep ".patch"` ]]; then
		target=`echo $patch | sed 's/\.patch//'`
		echo -e '\033[0;36m'Patching: '\033[0;31m'$target'\033[0m'
		cd $flarum_dir/$target
		patch -p1 < $patch_dir/$patch
	fi
done
