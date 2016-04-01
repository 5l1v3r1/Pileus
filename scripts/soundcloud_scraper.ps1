# soundcloud scraper

$CLIENT_ID = read-host "Soundcloud CLIENT_ID: "

$method = Read-Host "hashtag or track? "

if ($method -eq 'track'){
	# query soundcloud for our user. This gets us all the track_ids that we can then query for the dl link
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
} 
elseif ($method -eq 'hashtag'){
	
	$hashtag = Read-Host "[+]Hashtag: "
	$url_one = "http://api.soundcloud.com/tracks.json?client_id=$CLIENT_ID&tags=$hashtag"
	# gets the dl link for the tracks found with this hashtag
	$resp = invoke-webrequest $url_one | select -Expand Content | ConvertFrom-Json
	
	# we only want the 0th track because that's the most recent 
	$title = $resp[0].title
	$fname = "testing_$title.wma"
	
	$tmp = "?client_id=$CLIENT_ID"
	$dl_url = $resp[0].download_url + $tmp
	invoke-webrequest $dl_url -OutFile $fname
}

