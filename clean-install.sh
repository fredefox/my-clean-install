#!/usr/bin/bash
# Settings
GITHUB_USER="fredefox"
SHELL_SETTINGS_URL="https://gist.github.com/$GITHUB_USER/9352326/"
SHELL_SETTINGS_FILE="$HOME/.zshenv"
PACKAGE_LIST="packages.list"

# Return to cwd on exit
CWD=$(pwd)

# Debian packages to install
cat $PACKAGE_LIST | xargs -d '\n' sudo apt-get install

# Get shell configuration-file
curl SHELL_SETTINGS_URL -o $SHELL_SETTINGS_FILE

# Set up workspace
mkdir $HOME/workspace
cd $HOME/workspace

# Get list of github-repos
TMP=$(mktemp /tmp/repos-XXX)
curl https://api.github.com/users/fredefox/repos -o $TMP -s

# Clone all repos
for REPO in $(cat $TMP | jq ".[].git_url")
do
	# FIXME: This is not currently working
	# git clone $REPO
	echo $REPO
done
rm $TMP