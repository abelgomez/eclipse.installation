@echo off

PowerShell -ExecutionPolicy Bypass -File %~dp0\_install-eclipse-windows.ps1 -url "http://archive.eclipse.org/eclipse/downloads/drops4/R-4.5.2-201602121500/eclipse-SDK-4.5.2-win32-x86_64.zip" -version "mars"
