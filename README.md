# Aria2c Packload
A simple bash script to download content with aria2c in batch. 

The script [downloader.sh](./downloader.sh) requires a `\n` seperated download links file, and downloads content associated with each link in succession. Once a link content is downloaded, that link is removed from the links file.

# Setup
- Install `aria2c`
- The script is designed to work in a unix/linux environment or a compatible shell (ex: git bash for windows)
- Some variables like download/logs/download-links directoy and max download size for download directory can be configured in [downloader.sh](./downloader.sh)
- Make the script executable ex: `chmod +x ./downloader.sh` and run.