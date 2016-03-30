# windows bot 

# Name: 		find_string
# Parameters: 	$string (value to search)
# Return value:	returns an object containing the list of files
# Purpose: 		find all files containing a given string
function find_string ($string){
	$files = Get-ChildItem -recurse | select-string -pattern $string | group path | select name
	return $files
}

# Name:			take_screenshot
# Parameters:	None
# Return value:	$file (path to screenshot on local system)
# Purpose:		takes a screenshot and saves it in the format screenshot_yyyy-mm-dd_H_M_s.
function take_screenshot {
	$file = "C:\Users\whatbatman\screenshot_$(get-date -format yyyymm-dd_H_M_s).bmp"

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

