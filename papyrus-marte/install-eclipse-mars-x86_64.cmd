@echo off

PowerShell -ExecutionPolicy Bypass -File %~dp0\_install-eclipse-windows.ps1 -u "http://archive.eclipse.org/eclipse/downloads/drops4/R-4.5.2-201602121500/eclipse-SDK-4.5.2-win32-x86_64.zip" -v "mars" -f org.eclipse.papyrus.sdk.feature.feature.group,org.eclipse.papyrus.extra.marte.feature.feature.group,org.eclipse.papyrus.extra.marte.properties.feature.feature.group,org.eclipse.papyrus.extra.marte.textedit.feature.feature.group
