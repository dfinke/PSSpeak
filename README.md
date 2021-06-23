# PSSpeak

A PowerShell module that will hopefully make you more productive and even smarter.

Pass a single url or a list of RSS urls to `Invoke-PSSpeak`. 

```powershell

# Retrieves the latest news from the PowerShell blog
# Creates an audio file, at 1.5x speed
# From your listening pleasure

$url = 'https://devblogs.microsoft.com/powershell/feed/'

Invoke-PSSpeak -feed $url -Play
```

`Invoke-PSSpeak` will:
- Read the feeds
- Extract the title, link and contents
- Once all RSS entries are collected, it will use `Text to Speech` to create an audio file of the content.
- Lastly, it will optimize the audio file, increasing the tempo. So you can list to it at 1.5x the original speed

`'NEWS - 2021-Jun-Tue at 17-49 - 10 articles.mp3'` ready to be played.