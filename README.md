# Aria2c Packload
A simple bash script to download content with aria2c in batch. 

The [downloader.sh](./downloader.sh) script requires a `\n` seperated download links file, and downloads content associated with each link in succession. Once a link content is downloaded, that link is removed from the links file.

# Setup
- Install `aria2c`
- The script will work in any unix/linux environment or a compatible shell (ex: git bash for windows)
- These variables can be configured in [./downloader.sh](./downloader.sh)

| Variable                              | Comments                                               | Default value                         |
|---------------------------------------|--------------------------------------------------------|---------------------------------------|
| LOG_FILE                              | common log file dir                                    | `logs.txt` file in same dir           |
| DOWNLOAD_DIR                          | download directory                                     | `/downloads` folder in same dir       |
| DOWNLOAD_LINKS_FILE                   | file containing links to download                      | `download_links.txt` file in same dir |
| BAD_LINKS_FILE                        | file containing bad links from `DOWNLOAD_LINKS_FILE`   | `bad_links.txt` file in same dir      |
| TIMEOUT_WHEN_TORRENT_DOWNLOAD_SPEED_0 | timeout for torrent downloads when download speed is 0 | 10 minutes                            |
| MAX_DOWNLOAD_DIR_STORAGE_SIZE_IN_MBS  | max storage size of downloads folder                   | 20 gbs                                |

- Make the script executable ex: `chmod +x ./downloader.sh` and run.