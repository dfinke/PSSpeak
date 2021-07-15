$script:rootDirForSupportFiles = "."

function Invoke-PSSpeak {
    <#
        .Synopsis
        Retrieve from RSS feeds, and convert into a single MP3 file

        .Description
        Retrieve the latest news using RSS feeds, and use a Text to Speech (TTS) engine to convert those feeds into a single MP3 file

        .Example
        Invoke-PSSpeak -Play

        .Example
        Invoke-PSSpeak -Play

        .Example
        Invoke-PSSpeak https://feeds.npr.org/1001/rss.xml -Play

        .Example
        $rss = 'https://forum.devtalk.com/latest.rss', 'https://projects-raspberry.com/news-updates/raspberry-pi-news/feed/'
        Invoke-PSSpeak $rss -Play
    #>
    param(
        $feeds = 'https://devblogs.microsoft.com/powershell/feed/',
        [Switch]$Play
    )

    if (!$IsWindows) {
        'Sorry, only runs on Windows'
        return
    }
    
    # 'https://forum.devtalk.com/latest.rss'
    # 'https://feeds.npr.org/1001/rss.xml'
    # 'https://projects-raspberry.com/news-updates/raspberry-pi-news/feed/'

    #Write-Progress -Activity "Reading" -Status "Rss feeds"
    Write-Host -ForegroundColor green "Reading RSS feeds"
    $entries = @($feeds) | Get-FeedEntry

    $entriesFile = "$($script:rootDirForSupportFiles)\entries.txt"
    $outputMP3File = "$($script:rootDirForSupportFiles)\output.mp3"
    $fasterMP3File = "$($script:rootDirForSupportFiles)\faster.mp3"

    if ($entries.count -eq 0) {
        "Sorry, no new entries since last checking or an invalid RSS feed" > $entriesFile
    }
    else {
        $entries > $entriesFile     
    }
    
    Write-Host -ForegroundColor green "Text to Speech Creating audio file"
    &"$PSScriptRoot/bin/gtts-cli" --file $entriesFile --output $outputMP3File
    
    Write-Host -ForegroundColor green "Optimizing audio file - Increasing Tempo"
    &"$PSScriptRoot/bin/ffmpeg" -i $outputMP3File -filter:a "atempo=1.5" -vn -y $fasterMP3File

    $date = (Get-Date).ToString("yyyy-MMM-ddd")
    $time = '{0}-{1}-{2}-{3}' -f (Get-Date).Hour, (Get-Date).Minute, (Get-Date).Second, (Get-Date).Millisecond

    $newsMP3name = "$($script:rootDirForSupportFiles)\" 
    $newsMP3name += 'NEWS - {0} at {1} - {2} articles.mp3' -f $date, $time, $entries.Count

    Remove-Item $entriesFile
    Remove-Item $outputMP3File

    Rename-Item $fasterMP3File $newsMP3name

    if ($Play) { Invoke-Item $newsMP3name }
}

function Get-FeedEntry {
    param(
        [Parameter(ValueFromPipeline)]
        $url
    )

    Begin {
        $feedDataFile = "$($script:rootDirForSupportFiles)\feedata.csv"
        if (!(Test-Path $feedDataFile)) {
            "title, link`r`ndummy, dummy" | Set-Content $feedDataFile
        }
        
        $feedData = @(Import-Csv $feedDataFile)
    }

    Process {
        $r = Invoke-RestMethod $url 

        foreach ($item in $r) {
            if (!$item.title) { continue }

            if ($feedData.Where( { $_.link -eq $item.link }).Count -ge 1) {
            }
            else {
                $feedData += [PSCustomObject]@{title = $item.title; link = $item.link }

                $s = $item.description.'#cdata-section' -replace '<[^>]+>', ''

                @"
Start of blog post
$($item.title.ToUpper())
$([System.Web.HttpUtility]::HtmlDecode($s))

"@
            }
        }
    }

    End {
        $feedData | Export-Csv $feedDataFile        
    }
}