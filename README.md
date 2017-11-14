# Eclipse Installation Scripts

This repository contains a set of scripts to install different versions of Eclipse, with different configurations in different OS. 

**NOTE:** Eclipse will be installed in the **same directory** where the scripts below are located.

## Contents

### _install-eclipse-linux.sh 

Install Eclipse for Linux

```
Usage:
 _install-eclipse-linux.sh -u <url> -v <version> -f <features>
Options:"
 -u <url>      The URL
 -v <version>  Version name (Neon, Mars, Luna...)
 -f <features> Features to be installed
```

### _install-eclipse-macosx.command 

Install Eclipse for Mac OS X

```
Usage:
 _install-eclipse-macosx.command -u <url> -v <version> -f <features> [-l]
Options:"
 -u <url>      The URL
 -v <version>  Version name (Neon, Mars, Luna...)
 -f <features> Features to be installed
 -l            Legacy packaging (should be used with Luna and previous versions)
```

### _install-eclipse-windows.ps1 

Eclipse for Windows

```
Usage:
 _install-eclipse-windows.ps1 -u <url> -v <version> -f <features>
Options:"
 -u <url>      The URL
 -v <version>  Version name (Neon, Mars, Luna...)
 -f <features> Features to be installed
```

### papyrus-marte

Installation scripts to install Eclipse SDK, Papyrus, and the MARTE profile for Windows, Mac OS X and Linux x86-64.
