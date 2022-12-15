Import-Module BluebirdPS
Import-TwitterAuthentication
# Podcast RSS feed URL
$feedurl = 'https://powershellpodcast.podbean.com/feed.xml'
# PowerShell Podcast List ID
$list_id = '1590287371320233986'

[xml]$feed = Invoke-WebRequest -Uri $feedurl
$episodes = $feed.rss.channel.item
$handles = @()

# Parse the description for a twitter url
foreach ($episode in $episodes) {
  $s = $episode.description.InnerText | Select-String -Pattern 'twitter.com/(\w+)'
  if ($s.Matches.Success) {
    $handle = $s.Matches.value
    $handles += $handle.Replace('twitter.com/', '')
    Write-Host ('Episde {0}: {1}' -F $episode.Episode, $handle)
  } else {
    Write-Host ('No matches for Episode {0}' -F $episode.Episode)
    Write-Debug $episode.description.InnerText
  }
}

$existing = Get-TwitterListMember -Id $list_id
foreach ($handle in $handles) {
  if ($handle -in $existing.UserName) {
    Write-Host "🟰 $handle is already in the list."
  } else {
    Write-Host "➕ $handle is getting added to list."
    $user = Get-TwitterUser -User $handle
    Add-TwitterListMember -Id $list_id -User $user
  }
}
