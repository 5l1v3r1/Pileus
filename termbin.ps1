# writes to termbin for us so we don't need to install netcat everywhere

function Send-NetworkData ($data) {
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
Send-NetworkData "hi there"