#!/bin/bash

source "${0%/*}/_install-eclipse-macosx.command" \
  -u "http://archive.eclipse.org/eclipse/downloads/drops4/R-4.6.3-201703010400/eclipse-SDK-4.6.3-macosx-cocoa-x86_64.tar.gz" \
  -v "neon" \
  -f org.eclipse.papyrus.sdk.feature.feature.group,org.eclipse.papyrus.extra.marte.feature.feature.group,org.eclipse.papyrus.extra.marte.properties.feature.feature.group,org.eclipse.papyrus.extra.marte.textedit.feature.feature.group
