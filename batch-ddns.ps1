# This script is based on Andrew Bresciano's script
# You can find it here: http://andrewbresciano.com/about-me/personal-projects/googles-dynamic-dns-powershell-script

# Set csv file location here
$csvLocation = 'C:\Users\YOUR\FILE\PATH.csv'
# csv headers
# hostname,user,pass

# Enable result logging - set to 1 to enable else disables it
$doLogging = 1
$logPath = 'C:\Users\YOUR\FILE\PATH.txt'

#import csv list
$csvFile = import-csv $csvLocation
$csvFile | ForEach-Object {
    $hostname = $_.hostname
    $user = $_.user
    $pass = $_.pass

    # Basic Auth Formatting
    $secpasswd = ConvertTo-SecureString $pass -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($user, $secpasswd)

    # Get Current Authoratative IP For DynDNS Hostname
    $NS = (Resolve-DnsName $hostname -Server 8.8.8.8 -Type NS).PrimaryServer
    $ipCurrent = (Resolve-DnsName $hostname -Server $NS -Type A).IPAddress

    # Get Current Public IP
    $ipPub = (curl -uri 'https://ipv4.wtfismyip.com/text').Content.Trim()
    # You can use your preferred provider, I use wtfismyip.com because lols
    
    # Output
    "Host " + $hostname + " currently: " + $ipCurrent
    "Current machine IP: " + $ipPub
    
    # Set url destination
    $URL = "https://domains.google.com/nic/update?hostname=" + $hostname + "&myip=" + $ipPub

    # Logic
    if ($ipCurrent -eq $ipPub) {
        "IP still aligned. Does not need updating."
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
    }
