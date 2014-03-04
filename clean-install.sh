#!/bin/bash
# Get settings
source settings

# Return to cwd on exit
CWD=$(pwd)

# Allow aliasing
shopt -s expand_aliases

if [ ! $VERBOSE ]
then
	alias echo=false
fi

if [ $NO_PROMPT ]
then
	alias read=true
	alias apt-get="apt-get -y"
fi

# Check if shell settings file already exists
touch test
SHELL_SETTINGS_FILE=test
if [ -f $SHELL_SETTINGS_FILE ]
then
	echo "$SHELL_SETTINGS_FILE already exists"
	echo "Continuing will make a backup and replace"
	echo "current settings with these values."
	read -p "Do you want to continue [y/n]? " -n 1 -r
	echo
	if [[ ! $REPLY =~ ^[Yy]$ ]]
	then
	    exit 0
	fi
	BACKUP="$SHELL_SETTINGS_FILE-$(date +"%s").bak"
	mv $SHELL_SETTINGS_FILE $BACKUP
	echo "Backup placed in $BACKUP"
fi

# Select packages
dpkg --set-selections < $PACKAGE_LIST
# Install that
apt-get dselect-upgrade

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