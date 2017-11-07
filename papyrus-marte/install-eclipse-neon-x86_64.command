#!/bin/sh

# Basic functions
# Execute pushd command silently
function pushd {
    command pushd "$@" > /dev/null
}

# Execute popd command silently
function popd {
    command popd "$@" > /dev/null
}

# Fail the execution and exit with error
function fail {
  # Use a GUI dialog to notify about the error
  osascript -e "tell application (path to frontmost application as text) to display dialog \"$1\" buttons {\"OK\"} with icon stop" > /dev/null
  # Abort
  echo "Aborting..."
  exit 1;
}

# Check os type
if [[ $OSTYPE != "darwin"* ]]; then
  fail "Your OS ($OSTYPE) is not supported by this script!"
fi

# Link to Eclipse distribution
url=http://archive.eclipse.org/eclipse/downloads/drops4/R-4.6.3-201703010400/eclipse-SDK-4.6.3-macosx-cocoa-x86_64.tar.gz

# Eclipse version
Version="Neon"
version=$(echo "$Version" | tr '[:upper:]' '[:lower:]')

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
if [ -d "${0%/*}/Eclipse-$Version.app" ]; then
  fail "An existing installation of Eclipse lives in ${0%/*}. Please, delete it or run this script in another location.\n\nInstallation aborted."
fi

# Get the package of Eclipse SDK
echo "Getting installation package..."
curl --progress-bar $url -o $tmpfile

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
"$tmpdir/Eclipse.app/Contents/MacOS/eclipse" \
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
mv -n "$tmpdir/Eclipse.app" "${0%/*}/Eclipse-$Version.app"

# If Eclipse was successfully moved to its final location, launch it
if [ $? -eq 0 ]; then
  nohup "${0%/*}/Eclipse-$Version.app/Contents/MacOS/eclipse" &>/dev/null &disown
else
  fail "Unable to install Eclipse into $(pwd)"
fi

# Done!
echo "Done"
echo "************************************************************"
