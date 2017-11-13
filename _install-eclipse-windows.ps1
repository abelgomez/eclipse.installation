# Program parameters
param (
    [Parameter(Mandatory=$true)]$u,
    [Parameter(Mandatory=$true)]$v,
    [Parameter(Mandatory=$true)]$f
 )

# Fail the execution and exit with error
function Fail ($message) {
  # Notify about the error on a dialog
  $wshell = New-Object -ComObject Wscript.Shell
  $wshell.Popup($message,0,"Error",0x0) | Out-Null
  Write-Error "$message`r`nAborting..."
  #Abort
  Exit(1)
}

# Download a $url and save it in $targetFile
function Download($url, $targetFile) {
  $uri = New-Object "System.Uri" "$url"
  $request = [System.Net.HttpWebRequest]::Create($uri)
  $request.set_Timeout(60000)
  $response = $request.GetResponse()
  $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)
  $responseStream = $response.GetResponseStream()
  $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create
  try {
    $buffer = new-object byte[] 1024KB
    $count = $responseStream.Read($buffer,0,$buffer.length)
    $downloadedBytes = $count
    Write-Output "Downloading archive $url"
    Write-Output "Downloaded ($($downloadedBytes)K of $($totalLength)K) [0%]"
    $previous = Get-Date
    while ($count -gt 0) {
      $targetStream.Write($buffer, 0, $count)
      $count = $responseStream.Read($buffer,0,$buffer.length)
      $downloadedBytes = $downloadedBytes + $count
      $current = Get-Date
      if ((New-TimeSpan -Start $previous -End $current).TotalSeconds -gt 15) {
        $previous = $current
        $percent = [Math]::Round($downloadedBytes / 1024 / $totalLength * 100)
        Write-Output "Downloaded ($([System.Math]::Floor($downloadedBytes/1024))K of $($totalLength)K) [$percent%]"
      }
    }
    Write-Output "Downloaded ($($downloadedBytes)K of $($totalLength)K) [100%]"
  } Finally {
    $targetStream.Flush()
    $targetStream.Close()
    $targetStream.Dispose()
    $responseStream.Dispose()
  }
}

# Extract $zipfile in $outpath
function Unzip($zipfile, $outpath)
{
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

# Temp locations
$tmpfile = New-TemporaryFile
$tmpdir = New-TemporaryFile | %{ rm $_; mkdir $_ }

Try {

  # Save parameters into script variables
  $url = $u
  $version = $v
  $features = $f

  # Start!
  Write-Output "************************************************************"

  # Check, before starting the download and installations process, if there's
  # another Eclipse installation in the target folder that will prevent this
  # installation
  Write-Output "Checking previous installations..."
  if (Test-Path "$PSScriptRoot/eclipse-$version") {
    Fail "An existing installation of Eclipse lives in $PSScriptRoot. Please, delete it or run this script in another location. Installation aborted."
  }

  try {
    # Get the package of Eclipse SDK
    Write-Output "Getting installation package..."
    Download $url $tmpfile
  } Finally {
    # If the download was unsuccessful, fail
    if (-Not($?)) {
      Fail "Unable to download $url"
    }
  }

  try {
    # Extract
    Write-Output "Extracting $tmpfile into $tmpdir..."
    Unzip "$tmpfile" "$tmpdir"
  } Finally {
    # If the extraction was unsuccessful, fail
    if (-Not($?)) {
      Fail "An error occurred while extracting $tmpfile"
    }
  }
  
  try {
    # Go into the temp dir, where the Eclipse to be configured lives
    Push-Location $tmpdir
    # Start configuring Eclipse with Papyrus and MARTE
    Write-Output "Configuring (this may take a while, please be patient)..."
    eclipse\eclipsec.exe `
      -nosplash `
      -application org.eclipse.equinox.p2.director `
      -repository http://download.eclipse.org/releases/$version/,http://download.eclipse.org/modeling/mdt/papyrus/updates/releases/$version/ `
      -installIU $features
  } Finally {
    # Exit from the temp location
    Pop-Location
    # If the configuration was unsuccessful, fail
    if ($?) {
      Write-Output "Configurations finished"
    } else {
      Fail "An error occurred while configuring Eclipse"
    }
  }

  try {
    # Move Eclipse to its final location
    Write-Output "Installing..."
    Move-Item "$tmpdir/eclipse" "$PSScriptRoot/eclipse-$version"
  } Finally {
    # If Eclipse was successfully moved to its final location, launch it
    if ($?) {
      # Go to the Eclipse binary directory
      Push-Location $PSScriptRoot/eclipse-$version
	  # Execute Eclipse
      .\eclipse.exe
      # Go back to the initial location
      Pop-Location
    } else {
      Fail "Unable to install Eclipse into $PSScriptRoot"
    }
  }

  # Done!
  Write-Output "Done"
  Write-Output "************************************************************"

} Finally {
  Set-Location $PSScriptRoot
  Remove-Item -Force "$tmpfile"
  Remove-Item -Recurse -Force "$tmpdir"
}
