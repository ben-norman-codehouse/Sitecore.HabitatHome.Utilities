Param(
    [string] $ConfigurationFile = "configuration-xp0.json"
)

#####################################################
# 
#  Uninstall Sitecore
# 
#####################################################
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

if (!(Test-Path $ConfigurationFile)){
    Write-Host "Configuration file '$($ConfigurationFile)' not found." -ForegroundColor Red
    Write-Host  "Please use 'set-installation...ps1' files to generate a configuration file." -ForegroundColor Red
    Exit 1
}
$config =  Get-Content -Raw $ConfigurationFile -Force |  ConvertFrom-Json 
if (!$config){
    throw "Error trying to load configuration!"
}
$site = $config.settings.site
$sql = $config.settings.sql
$xConnect = $config.settings.xConnect
$sitecore = $config.settings.sitecore
$identityServer = $config.settings.identityServer
$solr = $config.settings.solr
$assets = $config.assets
$modules = $config.modules
$resourcePath = Join-Path $assets.root "configuration"

Write-Host "*******************************************************" -ForegroundColor Green
Write-Host " UNInstalling Sitecore $($assets.sitecoreVersion)" -ForegroundColor Green
Write-Host " Sitecore: $($site.hostName)" -ForegroundColor Green
Write-Host " xConnect: $($xConnect.siteName)" -ForegroundColor Green
Write-Host "*******************************************************" -ForegroundColor Green



# Remove App Pool membership 

try {
    Remove-LocalGroupMember "Performance Log Users" "IIS AppPool\$($site.hostName)"
    Write-Host "Removed IIS AppPool\$($site.hostName) to Performance Log Users" -ForegroundColor Green
  
}
catch {
    Write-Host "Warning: Couldn't remove IIS AppPool\$($site.hostName) to Performance Log Users -- user may already exist" -ForegroundColor Yellow
}
try {
    Remove-LocalGroupMember "Performance Monitor Users" "IIS AppPool\$($site.hostName)"
    Write-Host "Removed IIS AppPool\$($site.hostName) to Performance Monitor Users" -ForegroundColor Green
}
catch {
    Write-Host "Warning: Couldn't remove IIS AppPool\$($site.hostName) to Performance Monitor Users -- user may already exist" -ForegroundColor Yellow
}
try {
    Remove-LocalGroupMember "Performance Monitor Users" "IIS AppPool\$($xConnect.siteName)"
    Write-Host "Removed IIS AppPool\$($xConnect.siteName) to Performance Monitor Users" -ForegroundColor Green
}
catch {
    Write-Host "Warning: Couldn't remove IIS AppPool\$($site.hostName) to Performance Monitor Users -- user may already exist" -ForegroundColor Yellow
}
try {
    Remove-LocalGroupMember "Performance Log Users" "IIS AppPool\$($xConnect.siteName)"
    Write-Host "Removed IIS AppPool\$($xConnect.siteName) to Performance Log Users" -ForegroundColor Green
}
catch {
    Write-Host "Warning: Couldn't remove IIS AppPool\$($xConnect.siteName) to Performance Log Users -- user may already exist" -ForegroundColor Yellow
}


$singleDeveloperParams = @{
    Path                          = $sitecore.singleDeveloperConfigurationPath
    SqlServer                     = $sql.server
    SqlAdminUser                  = $sql.adminUser
    SqlAdminPassword              = $sql.adminPassword
    SitecoreAdminPassword         = $sitecore.adminPassword
    SolrUrl                       = $solr.url
    SolrRoot                      = $solr.root
    SolrService                   = $solr.serviceName
    Prefix                        = $site.hostName
    XConnectCertificateName       = $xconnect.siteName
    IdentityServerCertificateName = $identityServer.name
    IdentityServerSiteName        = $identityServer.name
    LicenseFile                   = $assets.licenseFilePath
    XConnectPackage               = $xConnect.packagePath
    SitecorePackage               = $sitecore.packagePath
    IdentityServerPackage         = $identityServer.packagePath
    XConnectSiteName              = $xConnect.siteName
    SitecoreSitename              = $site.hostName
    PasswordRecoveryUrl           = $site.hostName
    SitecoreIdentityAuthority     = $identityServer.name
    XConnectCollectionService     = $xConnect.siteName
    ClientSecret                  = $identityServer.clientSecret
    AllowedCorsOrigins            = $site.hostName
}
Push-Location $resourcePath
Install-SitecoreConfiguration @singleDeveloperParams -Uninstall  *>&1 | Tee-Object XP0-SingleDeveloper.log
Pop-Location
