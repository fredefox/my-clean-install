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

# Clone all repos from users repo's
for REPO in $(cat $TMP | jq '.[4,5].git_url' |
	# Remove leading quote
	# Change protocol to https
	# Add user-name
	# TODO: Figure out how to stay on the git-protocol
	# while still being able to supply username
	sed "s/^\"git:\/\//https:\/\/$GITHUB_USER@/g" |
	# Remove trailing quote
	sed "s/\"$//g")
do
	git clone $REPO
done
rm $TMP