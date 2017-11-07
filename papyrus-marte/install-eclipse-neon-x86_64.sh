#!/bin/bash

# Basic functions
# Execute pushd command silently
function pushd {
    command pushd "$@" > /dev/null
}

# Execute popd command silently
function popd {
    command popd "$@" > /dev/null
}

function download {
    if hash curl 2>/dev/null; then
        curl --progress-bar $1 -o $2
    elif hash wget 2>/dev/null; then
        wget --show-progress -q --progress=bar -O $2 $1
    else
        fail "Unable to find a binary to download Eclipse. Please install 'curl' or 'wget'."
    fi
}

# Fail the execution and exit with error
function fail {
  # Notify about the error on stderr
  >&2 echo "$1"
  # Abort
  >&2 echo "Aborting..."
  exit 1;
}

# Check OS type (mainly to avoid running this script in non-Linux environments)
if [[ $OSTYPE != "linux-gnu" ]]; then
  fail "Your OS ($OSTYPE) is not supported by this script!"
fi

# Link to Eclipse distribution
url=http://archive.eclipse.org/eclipse/downloads/drops4/R-4.6.3-201703010400/eclipse-SDK-4.6.3-linux-gtk-x86_64.tar.gz

# Eclipse version
version="mars"

# Temp locations
tmpfile=$(mktemp)
tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'eclipse-installer')

# Ensure that the temp files are always cleaned up
trap 'rm -rf -- "$tmpfile" "$tmpdir"' INT TERM HUP EXIT

# Start!
echo "************************************************************"

# Check, before starting the download and installations process, if there's
# another Eclipse installation in the target folder that will prevent this
# installation
echo "Checking previous installations..."
if [ -d "${0%/*}/eclipse-$version" ]; then
  fail "An existing installation of Eclipse lives in ${0%/*}. Please, delete it or run this script in another location.\n\nInstallation aborted."
fi
echo mv -n "$tmpdir/eclipse" "${0%/*}/eclipse-$version"
# Get the package of Eclipse SDK
echo "Getting installation package..."
download $url $tmpfile

# If the download was unsuccessful, fail
if [ $? -ne 0 ]; then
  fail "Unable to download $url"
fi

# Go into the temp dir, where the Eclipse packages will be extracted
pushd $tmpdir

# Extract
echo "Extracting..."
tar xzf $tmpfile

# If the extraction was unsuccessful, fail
if [ $? -ne 0 ]; then
  fail "An error occurred while extracting $tmpfile"
fi

# Start configuring Eclipse with Papyrus and MARTE
echo "Configuring (this may take a while, please be patient)..."
"$tmpdir/eclipse/eclipse" \
   -nosplash \
   -application org.eclipse.equinox.p2.director \
   -repository http://download.eclipse.org/releases/$version/,http://download.eclipse.org/modeling/mdt/papyrus/updates/releases/$version/\
   -installIU org.eclipse.papyrus.sdk.feature.feature.group,org.eclipse.papyrus.extra.marte.feature.feature.group,org.eclipse.papyrus.extra.marte.properties.feature.feature.group,org.eclipse.papyrus.extra.marte.textedit.feature.feature.group

# If the configuration was unsuccessful, fail
if [ $? -ne 0 ]; then
  fail "An error occurred while configuring Eclipse"
else
  echo "Configurations finished"
fi

# Exit from the temp location
popd

# Move Eclipse to its final location
echo "Installing..."
mv -n "$tmpdir/eclipse" "${0%/*}/eclipse-$version"

# If Eclipse was successfully moved to its final location, launch it
if [ $? -eq 0 ]; then
  nohup "${0%/*}/eclipse-$version/eclipse" &>/dev/null &disown
else
  fail "Unable to install Eclipse into $(pwd)"
fi

# Done!
echo "Done"
echo "************************************************************"