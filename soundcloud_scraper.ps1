# soundcloud scraper

$CLIENT_ID = read-host "Soundcloud CLIENT_ID: "

# query soundcloud 
$url_one = "http://api.soundcloud.com/resolve.json?url=https://soundcloud.com/user-212129295/tracks&client_id=$CLIENT_ID"

$resp = invoke-webrequest $url_one | select -Expand Content | ConvertFrom-Json
$track_id = $resp[0].id

# gets the download link for the track. You need to escape the variable being used apparently? hence \$track_id\
$dl = Invoke-WebRequest "http://api.soundcloud.com/tracks/\$track_id\?client_id=$CLIENT_ID" | select -Expand Content | ConvertFrom-Json

$title = $dl.title
$fname = "testing_$title.wma"

$tmp = "?client_id=$CLIENT_ID"
$dl_url = $dl.download_url + $tmp

write-host "[+]URL --> $dl_url"
invoke-webrequest $dl_url -OutFile $fname