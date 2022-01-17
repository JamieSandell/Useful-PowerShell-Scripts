[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Send-MailMessage
{
    Param
    (
        [Parameter(Mandatory = $false)] [String[]] $Attachments,
        [Parameter(Mandatory = $false)] [String[]] $Bcc,
        [Parameter(Mandatory = $false)] [String] $Body,
        [Parameter(Mandatory = $false)] [Switch] $BodyAsHTML,
        [Parameter(Mandatory = $false)] [System.Text.Encoding] $Encoding,
        [Parameter(Mandatory = $false)] [String[]] $Cc,
        [Parameter(Mandatory = $false)] [System.Net.Mail.DeliveryNotificationOptions] $DeliveryNotificationOptions,
        [Parameter(Mandatory = $true)] [String] $From,
        [Parameter(Mandatory = $false)] [String] $SMTPServer = 'cluster8out.eu.messagelabs.com',
        [Parameter(Mandatory = $false)] [String] $Priority,
        [Parameter(Mandatory = $true)] [String] $Subject,
        [Parameter(Mandatory = $true)] [String[]] $To,
        [Parameter(Mandatory = $false)] [pscredential] $Credential,
        [Parameter(Mandatory = $false)] [switch] $UseSSL,
        [Parameter(Mandatory = $false)] [int] $Port
    )
    
    #region Build the E-mail
    $MailMessage = @{}

    if ($Attachments)
    {
        $MailMessage.Attachments = $Attachments
    }

    if ($Bcc)
    {
        $MailMessage.Bcc = $Bcc
    }

    if ($Body)
    {
        $MailMessage.Body = $Body
    }

    if ($BodyAsHTML)
    {
        $MailMessage.BodyAsHTML = $BodyAsHTML
    }

    if ($Encoding)
    {
        $MailMessage.Encoding = $Encoding
    }

    if ($Cc)
    {
        $MailMessage.Cc = $Cc
    }

    if ($DeliveryNotificationOptions)
    {
        $MailMessage.DeliveryNotifcationOptions = $DeliveryNotificationOptions
    }

    if ($From)
    {
        $MailMessage.From = $From
    }

    if ($SMTPServer)
    {
        $MailMessage.SMTPServer = $SMTPServer
    }

    if ($Prority)
    {
        $MailMessage.Priority = $Prority
    }

    if ($Subject)
    {
        $MailMessage.Subject = $Subject
    }

    if ($To)
    {
        $MailMessage.To = $To
    }

    if($Credential)
    {
        $MailMessage.Credential = $Credential
    }

    if ($UseSSL)
    {
        $MailMessage.UseSSL = $UseSSL
    }

    if ($Port)
    {
        $MailMessage.Port = $Port
    }
    #endregion

    #Send the e-mail based upon the argument list we built earlier, a.k.a Splatting
    Microsoft.PowerShell.Utility\Send-MailMessage @MailMessage
}

Export-ModuleMember -Function Send-MailMessage