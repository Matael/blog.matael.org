#! /bin/bash
#
# setup.sh
#
# Copyright © 2017 Mathieu Gaborit (matael) <mathieu@matael.org>
#
# Licensed under the "THE BEER-WARE LICENSE" (Revision 42):
# Mathieu (matael) Gaborit wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer or coffee in return
#
# Set up the directory for website building

VIRTUALENV=$(whereis virtualenv | cut -d" " -f2)
PY=$(whereis python3 | cut -d" " -f2)

$VIRTUALENV -ppython3 .venv
source .venv/bin/activate
pip --no-cache-dir install -r requirements.txt


