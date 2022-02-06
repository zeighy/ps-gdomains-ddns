# This script is based on Andrew Bresciano's script
# You can find it here: http://andrewbresciano.com/about-me/personal-projects/googles-dynamic-dns-powershell-script

# Vars
$hostname = 'YOUR.HOSTNAME.HERE'
$user = 'USERNAME'
$pass = 'PASSWORD'

# Enable result logging - set to 1 to enable anything else disables it
$doLogging = 1
$logPath = 'C:\Users\YOUR\FILE\PATH.txt'

# Basic Auth Formatting
$secpasswd = ConvertTo-SecureString $pass -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($user, $secpasswd)

# Get Current Authoratative IP For DynDNS Hostname
$NS = (Resolve-DnsName $hostname -Server 8.8.8.8 -Type NS).PrimaryServer
$ipCurrent = (Resolve-DnsName $hostname -Server $NS -Type A).IPAddress

# Get Current Public IP
$ipPub = (curl -uri 'https://ipv4.wtfismyip.com/text').Content.Trim()
# I used wtfismyip.com because lols. You can use whichever provider you like.

# Output
"Host " + $hostname + " currently: " + $ipCurrent
"Current machine IP: " + $ipPub
$URL = "https://domains.google.com/nic/update?hostname=" + $hostname + "&myip=" + $ipPub

# Logic
if ($ipCurrent -eq $ipPub) {
    "IP still aligned. Does not need updating."

    # Logging, replace the destination
    if ($doLogging -eq 1) {
        Write-Output "$(Get-Date -Format "yyyy/MM/dd HH:mm") : $hostname $ipCurrent does not require update" | Out-File $logPath -Append -Encoding utf8
    }
}

Else {
    "Updating from: " + $ipCurrent + " to: " + $ipPub
    $result = Invoke-RestMethod $URL -Credential $credential
    "Server Response: " + $result
    if ($doLogging -eq 1) {
        Write-Output "$(Get-Date -Format "yyyy/MM/dd HH:mm") : $hostname $result from $ipCurrent" | Out-File $logPath -Append -Encoding utf8
    }
}
