<#
    .SYNOPSIS
        Downloads and configures GPS Server for Synnex
#>

Param (
    [string]$apiAppURI,
    [string]$adAppId,
    [string]$adClientSecret,
    [string]$adTenantName,
    [string]$restServer
)

# Firewall
netsh advfirewall firewall add rule name="http" dir=in action=allow protocol=TCP localport=80

# Folders
New-Item -ItemType Directory c:\temp
New-Item -ItemType Directory c:\gpsServer

# Install iis
# Install-WindowsFeature web-server -IncludeManagementTools

# Install dot.net core sdk
# Invoke-WebRequest http://go.microsoft.com/fwlink/?LinkID=615460 -outfile c:\temp\vc_redistx64.exe
# Start-Process c:\temp\vc_redistx64.exe -ArgumentList '/quiet' -Wait
# Invoke-WebRequest https://go.microsoft.com/fwlink/?LinkID=809122 -outfile c:\temp\DotNetCore.1.0.0-SDK.Preview2-x64.exe
# Start-Process c:\temp\DotNetCore.1.0.0-SDK.Preview2-x64.exe -ArgumentList '/quiet' -Wait
# Invoke-WebRequest https://go.microsoft.com/fwlink/?LinkId=817246 -outfile c:\temp\DotNetCore.WindowsHosting.exe
# Start-Process c:\temp\DotNetCore.WindowsHosting.exe -ArgumentList '/quiet' -Wait
Invoke-WebRequest https://nodejs.org/dist/v9.8.0/node-v9.8.0-x64.msi -outfile c:\temp\node-v9.8.0-x64.msi
Start-Process -FilePath "$env:systemroot\system32\msiexec.exe" -ArgumentList "/i `"C:\temp\node-v9.8.0-x64.msi`"" , "/qn" -Wait


# Download music app
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest http://github.com/surabhshah/VMExtension/raw/master/GPSServer.zip -OutFile c:\temp\GPSServer.zip
Expand-Archive C:\temp\GPSServer.zip c:\gpsServer

# Azure SQL connection sting in environment variable
[Environment]::SetEnvironmentVariable("CUSTOMCONNSTR_AdResource", $apiAppURI, [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("CUSTOMCONNSTR_AdApplicationId", $adAppId, [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("CUSTOMCONNSTR_AdClientSecret", $adClientSecret, [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("CUSTOMCONNSTR_RestServer", $restServer, [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("CUSTOMCONNSTR_AdTenantName", $adTenantName, [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("CUSTOMCONNSTR_DeviceName", "SynnexGPSGateway", [EnvironmentVariableTarget]::Machine)

#Start Node Server
cp "C:\gpsServer\GPSServer\serverRun.cmd" "C:\Users\$env:USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
start "C:\Program Files\nodejs\npm.cmd" "install C:\gpsServer\GPSServer" -Wait
start "C:\Program Files\nodejs\node.exe" "C:\gpsServer\GPSServer\server.js"

# Pre-create database
# $env:Data:DefaultConnection:ConnectionString = "Server=$sqlserver;Database=MusicStore;Integrated Security=False;User Id=$user;Password=$password;MultipleActiveResultSets=True;Connect Timeout=30"
# Start-Process 'C:\Program Files\dotnet\dotnet.exe' -ArgumentList 'c:\music\MusicStore.dll'

# Configure iis
# Remove-WebSite -Name "Default Web Site"
# Set-ItemProperty IIS:\AppPools\DefaultAppPool\ managedRuntimeVersion ""
# New-Website -Name "MusicStore" -Port 80 -PhysicalPath C:\music\ -ApplicationPool DefaultAppPool
# & iisreset