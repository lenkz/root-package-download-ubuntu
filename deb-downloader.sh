#!/bin/bash -ex
function do-install {
	# skip packages which are already being installed
	if grep -q "^$1\$" packages ; then return ; fi
	echo "$1" >> packages
	apt-cache depends --important "$1" | while read -r line ; do
		pkg="${line#Depends: }"
		if test "$pkg" != "$line" -a "${pkg#<}" = "$pkg" ; then
			do-install "$pkg"
		fi
	done
}

# mark arguments and their dependencies recursively for install
for i in "$@" ; do
	do-install "$i"
done

# download all marked packages
aptitude download `cat packages`
