#!/bin/bash
if [ $# -eq 0 ]; then
    echo "No arguments provided, please specify which binary to download with -p argument."
    echo "Supported binaries are packer and terraform"
    echo "Example: $0 -p packer"
    exit 1
fi
while getopts ":p:" opt; do
	case $opt in
		p)
			if [[ "${OPTARG}" == +(terraform|packer) ]]; then
				PROGRAM=$OPTARG
			else
				echo 'Wrong binary name, please choose lower case "terraform" or "packer."'
				exit 1
			fi
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			;;
	esac
done


ARCH=$(uname -m)
URL="https://www.$PROGRAM.io/downloads.html"
BINPATH=".local/bin"


case $ARCH in
	x86_64)
		url_arch="amd64"
		;;
	i386)
		url_arch="386"
		;;
	arm?*)
		url_arch="arm"
		;;
	*)
esac

if (unzip>/dev/null 2>&1);then
	echo "Unzip is installed, carrying on ..."
else
	echo "Please install unzip first."
	exit 1
fi

downloadURL=$(curl -s $URL|grep -oP "http.?://\S+linux\S$url_arch.+zip")
version=$(echo $downloadURL|egrep -o "\/([0-9]{1,}\.)+[0-9]{1,}\/"|sed 's/\///g')
downloadCMD="curl -so /tmp/$PROGRAM.zip $downloadURL"

echo "Architecture is : $ARCH"
echo "Latest terraform version is : $version "
echo "Download URL is : $downloadURL"
echo "Downloading ..."

if $($downloadCMD);then
	mkdir -p $HOME/$BINPATH
	unzip -q -o /tmp/$PROGRAM.zip -d $HOME/$BINPATH
	checkver=$($HOME/$BINPATH/$PROGRAM -v|egrep -o "([0-9]{1,}\.)+[0-9]{1,}")
	if [[ "$checkver" == "$version" ]]; then
		echo "$PROGRAM $version succesfully installed to $HOME/$BINPATH"
		case ":$PATH:" in
		  (*:$HOME/$BINPATH:*)
			  ;;
		  (*) 
			  echo "$HOME/$BINPATH is not in your \$PATH."
			  echo "Please add : \"export PATH=\$PATH:\$HOME/$BINPATH\" to your .bashrc file"
			  ;;
		esac
		rm -rf /tmp/$PROGRAM.zip

	fi
else
	echo "Download unsuccesfull"
	exit 1
fi

