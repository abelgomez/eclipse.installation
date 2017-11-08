@echo off

PowerShell -ExecutionPolicy Bypass -File %~dp0\_install-eclipse-windows.ps1 -url "http://archive.eclipse.org/eclipse/downloads/drops4/R-4.4.2-201502041700/eclipse-SDK-4.4.2-win32-x86_64.zip" -version "luna"
