﻿    # Download XMPP SDK from http://www.ag-software.de/index.php?page=agsxmpp-sdk
    function Send-XmppMessage {
            param (
                    $From = $( Throw "You must specify a Jabber ID for the sender." ),
                    $Password, # Leave blank to be prompted for password
                    $To = $( Throw "You must specify a Jabber ID for the recipient." ),
                    $Body = $( Throw "You must specify a body for the message." )
            )
           
            # This function reads a string from the host while masking with *'s.
            function Read-HostMasked( [string]$prompt="Password" ) {
                    $password = Read-Host -AsSecureString $prompt;
                    $BSTR = [System.Runtime.InteropServices.marshal]::SecureStringToBSTR($password);
                    $password = [System.Runtime.InteropServices.marshal]::PtrToStringAuto($BSTR);
                    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR);
                    return $password;
            }
            # Set path accordingly.
#            $assemblyPath = $(resolve-path $profiledir\Assemblies\agsXMPP.dll)
            $assemblyPath = $(resolve-path 'c:\util\scripts\agsXMPP.dll')
            [void][reflection.assembly]::LoadFrom( $assemblyPath )
            $jidSender              = New-Object agsxmpp.jid( $From )
            $jidReceiver    = New-Object agsxmpp.jid ( $To )
            $xmppClient     = New-Object agsxmpp.XmppClientConnection( $jidSender.Server )
            $Message                = New-Object agsXMPP.protocol.client.Message( $jidReceiver, $Body )
           
            # The following switches may assist in troubleshooting connection issues.
            # If SSL and StartTLS are disabled, then you can use a network sniffer to inspect the XML
            #$xmppClient.UseSSL                                     = $FALSE
            #$xmppClient.UseStartTLS                                = $FALSE
           
            # Since this function is only used to send a message, we don't care about doing the
            # normal discovery and requesting a roster.  Leave disabled to quicken the login period.
            $xmppClient.AutoAgents                                  = $FALSE
            $xmppClient.AutoRoster                                  = $FALSE
           
            # Use SRV lookups to determine correct XMPP server if different from the server
            # portion of your JID.  e.g. user@gmail.com, the server is really talk.google.com
            $xmppClient.AutoResolveConnectServer    = $TRUE
            if ( !$password ) { $password = Read-HostMasked }
           
            # Open connection, then wait for it to be authenticated
            $xmppClient.Open( $jidSender.User, $Password )
                    while ( !$xmppClient.Authenticated ) {
                            Write-Verbose $xmppClient.XmppConnectionState
                            Start-Sleep 1
                    }
            # If server disconnects you, try enabling this
            #$xmppClient.SendMyPresence()
            $xmppClient.Send( $Message )
            # Send is asynchronous, so we must wait a second before closing the connection
            Start-Sleep 1
            $xmppClient.Close()
    }

    Send-XmppMessage -From robert.koch@192.168.1.5 -Password jav11* -To fabiano.fernandes -Body teste
