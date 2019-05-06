

# Ansible: How to delete files and folders inside a directory? - Stack Overflow
 https://stackoverflow.com/questions/38200732/ansible-how-to-delete-files-and-folders-inside-a-directory

 Using shell module:

- shell: /bin/rm -rf /home/mydata/web/*
Cleanest solution if you don't care about creation date:

- file: path=/home/mydata/web state=absent
- file: path=/home/mydata/web state=directory