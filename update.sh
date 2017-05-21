#! /bin/bash
#
# update.sh
#
# Copyright © 2017 Mathieu Gaborit (matael) <mathieu@matael.org>
#
# Licensed under the "THE BEER-WARE LICENSE" (Revision 42):
# Mathieu (matael) Gaborit wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer or coffee in return
#
# Update script for CMI website

cd /var/www/blog.matael.org

# test if .venv is present and activate it
if [[ ! -d .venv/bin ]]; then
	echo "Virtualenv not present."
	echo "Please run ./setup.sh to build it in .venv/ and rerun."
	exit 1
else
	source .venv/bin/activate
fi

# update repo
git pull
# build
returnval=$(make publish)

if [[ ! $returnval ]]; then
	echo "Echo an error occured while building. Please proceed manually."
else
	echo "Build passed."
	echo "Syncing..."
	rsync -a output/ ../prod
	echo "Synced."
fi


