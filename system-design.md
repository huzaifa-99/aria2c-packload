# Overview
A simple script to download content in batch using `aria2c`. It would
- read a link from a `\n` seperated download links file
- use `aria2c` (in background) to download content associated with that link
- once that link content is download, remove it from the links file
- and read the next link and start downloading its associated content
- repeat this process until all links are downloaded

# Exit Cases
- if there is no links file, then exit
- if there are no links in links file, then exit
- if download directory doesn't exist, and its not possible to create one, then exit.
- if script is interrupted (SIGINT/SIGTERM), it should stop `aria2c` background process, then exit. And alternatively when script is started again, the download should continue from where it was interrupted.
- before starting a download, the download directory size must be validated, if the directory size exceeds the allowed size, then exit.

# Monitoring
- script actions should be save to a log file
- `aria2c` logs should be saved to a log file

# Assumptions
- Working internet
- All links in links file are valid links for `aria2c` (for magnet links assuming >=1 seeders)
- All links in links file are newline seperated
- Script is running in a unix/linux environment or a compatible shell (ex: git bash for windows)
- `aria2c` is configured on the system and accessible via `aria2c` in the global cli environment
- The download directory is only changed if there is no active or paused (interrupted) download. Otherwise `aria2c` will restart the half-downloaded content.
