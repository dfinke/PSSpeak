# PSSpeak

A PowerShell module that will hopefully make you more productive and even smarter.

Pass a single url or a list of RSS urls to `Invoke-PSSpeak`. 

`Invoke-PSSpeak` will:
- Read the feeds
- Extract the title, link and contents
- Check to see if that entry was previously processed
- If not, adds it to the list
- Once all RSS entries are collected, it will use `Text to Speech` to create an audio file
- Lastly, it will optimize the audio file, increasing the tempo. So you can list to it at 1.5x the original speed