
* [18 Tar Command Examples in Linux ](https://www.tecmint.com/18-tar-command-examples-in-linux/)

```sh
#1. Create tar Archive File
tar -cvf tecmint-14-09-12.tar /home/tecmint/
#c – Creates a new .tar archive file.
#v – Verbosely show the .tar file progress.
#f – File name type of the archive file.
#2. Create tar.gz Archive File
tar cvzf MyImages-14-09-12.tar.gz /home/MyImages
#OR
tar cvzf MyImages-14-09-12.tgz /home/MyImages
#3. Create tar.bz2 Archive File
tar cvfj Phpfiles-org.tar.bz2 /home/php
#OR
tar cvfj Phpfiles-org.tar.tbz /home/php
#OR 
tar cvfj Phpfiles-org.tar.tb2 /home/php
#4. Untar tar Archive File
## Untar files in Current Directory ##
tar -xvf public_html-14-09-12.tar
## Untar files in specified Directory ##
tar -xvf public_html-14-09-12.tar -C /home/public_html/videos/
#5. Uncompress tar.gz Archive File
tar -xvf thumbnails-14-09-12.tar.gz
#6. Uncompress tar.bz2 Archive File
tar -xvf videos-14-09-12.tar.bz2
#7. List Content of tar Archive File
tar -tvf uploadprogress.tar
#8. List Content tar.gz Archive File
tar -tvf staging.tecmint.com.tar.gz
#9. List Content tar.bz2 Archive File
tar -tvf Phpfiles-org.tar.bz2
#10. Untar Single file from tar File
tar -xvf cleanfiles.sh.tar cleanfiles.sh
#OR
tar --extract --file=cleanfiles.sh.tar cleanfiles.sh
cleanfiles.sh
#11. Untar Single file from tar.gz File
tar -zxvf tecmintbackup.tar.gz tecmintbackup.xml
#OR
tar --extract --file=tecmintbackup.tar.gz tecmintbackup.xml
tecmintbackup.xml
#12. Untar Single file from tar.bz2 File
tar -jxvf Phpfiles-org.tar.bz2 home/php/index.php
#OR
tar --extract --file=Phpfiles-org.tar.bz2 /home/php/index.php
/home/php/index.php
#13. Untar Multiple files from tar, tar.gz and tar.bz2 File
tar -xvf tecmint-14-09-12.tar "file 1" "file 2" 
tar -zxvf MyImages-14-09-12.tar.gz "file 1" "file 2" 
tar -jxvf Phpfiles-org.tar.bz2 "file 1" "file 2"
#14. Extract Group of Files using Wildcard
tar -xvf Phpfiles-org.tar --wildcards '*.php'
tar -zxvf Phpfiles-org.tar.gz --wildcards '*.php'
tar -jxvf Phpfiles-org.tar.bz2 --wildcards '*.php'
#15. Add Files or Directories to tar Archive File
tar -rvf tecmint-14-09-12.tar xyz.txt
tar -rvf tecmint-14-09-12.tar php
#16. Add Files or Directories to tar.gz and tar.bz2 files
tar -rvf MyImages-14-09-12.tar.gz xyz.txt
tar -rvf Phpfiles-org.tar.bz2 xyz.txt
#17. How To Verify tar, tar.gz and tar.bz2 Archive File
tar tvfW tecmint-14-09-12.tar
#18. Check the Size of the tar, tar.gz and tar.bz2 Archive File
tar -czf - tecmint-14-09-12.tar | wc -c
tar -czf - MyImages-14-09-12.tar.gz | wc -c
tar -czf - Phpfiles-org.tar.bz2 | wc -c
#Tar Usage and Options
#c – create a archive file.
#x – extract a archive file.
#v – show the progress of archive file.
#f – filename of archive file.
#t – viewing content of archive file.
#j – filter archive through bzip2.
#z – filter archive through gzip.
#r – append or update files or directories to existing archive file.
#W – Verify a archive file.
#wildcards – Specify patterns in unix tar command.
```