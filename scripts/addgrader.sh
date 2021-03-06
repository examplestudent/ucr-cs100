#!/bin/bash

#
# This script is used to add a new grader to the class.
# It must be run on the computer the grader will be using to grade assignments.
#

scriptdir=`dirname "$0"`
source "$scriptdir/config.sh"

#######################################

echo "extracting user information from ~/.gitconfig"
name=$(git config --get user.name)
email=$(git config --get user.email)
echo "  name:  $name"
echo "  email: $email"

if [ -z "$email" ] || [ -z "$name" ]; then
    echo "ERROR: either name or email is not configured; please run the commands:"
    echo " $ git config --global user.name \"your name here\""
    echo " $ git config --global user.email \"your email here\""
fi

#######################################

echo "generating gpg key; this may take a while..."

gpg --batch --gen-key <<EOF 
    Key-Type: RSA
    Key-Length: 4096
    Name-Real: $name
    Name-Email: $email
EOF

key=$(gpg --list-keys | tail -3 | head -1 | cut -c 13,14,15,16,17,18,19,20)
echo
echo "adding key $key to configuration file"
git config user.signingkey "$key"

#######################################

echo "
output="$instructorinfo/$email"
echo "exporting new key to $output"
gpg --output "$output --export "$email"
echo "adding key to class repository"
git add "$output"
git commit -m "added instructor $name <$email> to class"
git push origin
