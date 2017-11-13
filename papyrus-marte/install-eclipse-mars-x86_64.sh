#!/bin/bash

source "${0%/*}/../_install-eclipse-linux.sh" \
  -u "http://archive.eclipse.org/eclipse/downloads/drops4/R-4.5.2-201602121500/eclipse-SDK-4.5.2-linux-gtk-x86_64.tar.gz" \
  -v "mars" \
  -f org.eclipse.papyrus.sdk.feature.feature.group,org.eclipse.papyrus.extra.marte.feature.feature.group,org.eclipse.papyrus.extra.marte.properties.feature.feature.group,org.eclipse.papyrus.extra.marte.textedit.feature.feature.group
