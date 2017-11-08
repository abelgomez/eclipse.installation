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

# Fail the execution and exit with error
function fail {
  if hash osascript 2>/dev/null; then
    # Use a GUI dialog to notify about the error
    osascript -e "tell application (path to frontmost application as text) to display dialog \"$1\" buttons {\"OK\"} with icon stop" > /dev/null
  else
    >&2 echo -e "$1"
  fi
  # Abort
  echo "Aborting..."
  exit 1;
}

# Prints the script help
# Note: The legacy option should be used with versions
# prior to Eclipse Luna (including)
function usage {
    echo "Install Eclipse version from URL"
    echo "Usage:"
    echo " $0 -u <url> -v <version> [-l]"
    echo "Options:"
    echo " -u <url>      The URL"
    echo " -v <version>  Version name (Neon, Mars, Luna...)"
    echo " -l            Legacy packaging (should be used with Luna and previous versions)"
}

# Check os type
if [[ $OSTYPE != "darwin"* ]]; then
  fail "Your OS ($OSTYPE) is not supported by this script!"
fi

# Execute getopt
args=$(getopt "u:v:l" "$@");

# Bad arguments
if [ $? -ne 0 ]; then
  usage
  exit 1
fi

# Update args
eval set -- "$args";

legacy=false

while true; do
  case "$1" in
    -u)
      url=$2
      shift 2
      ;;
    -v)
      version=$2
      shift 2
      ;;
    -l)
      legacy=true
      shift
      ;;
    --)
      shift;
      break;
      ;;
    esac
done

# Ensure the input argument are defined
if [ -z $url ] || [ -z $version ]; then
  usage
  if [ -z $url ]; then
    echo "Error: url argument undefined"
  fi  
  if [ -z $version ]; then
    echo "Error: version argument undefined"
  fi
  exit 1
fi  


Version="$(tr '[:lower:]' '[:upper:]' <<< ${version:0:1})$(tr '[:upper:]' '[:lower:]' <<< ${version:1})"
version="$(echo "$Version" | tr '[:upper:]' '[:lower:]')"

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

destdir="${0%/*}/Eclipse-$Version.app"
if [ $legacy = true ]; then
	destdir="${0%/*}/Eclipse-$Version"
fi

if [ -d "$destdir" ]; then
  fail "An existing installation of Eclipse lives in '${0%/*}'. Please, delete it or run this script in another location.\n\nInstallation aborted."
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

origdir="$tmpdir/Eclipse.app"
origextra=""
if [ $legacy = true ]; then
	origdir="$tmpdir/eclipse"
	origextra="/Eclipse.app"
fi

# Start configuring Eclipse with Papyrus and MARTE
echo "Configuring (this may take a while, please be patient)..."
"$origdir$origextra/Contents/MacOS/eclipse" \
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
mv -n "$origdir" "$destdir"

# If Eclipse was successfully moved to its final location, launch it
if [ $? -eq 0 ]; then
  # Go to the Eclipse binary directory
  pushd "$destdir"
  # Execute Eclipse
  nohup "$destdir/Contents/MacOS/eclipse" &>/dev/null &disown
  # Go back
  popd
else
  fail "Unable to install Eclipse into $(pwd)"
fi

# Done!
echo "Done"
echo "************************************************************"
