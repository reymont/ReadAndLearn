

Groovy : get a list of all the files in a directory (recursive) - Stack Overflow 
https://stackoverflow.com/questions/3953965/groovy-get-a-list-of-all-the-files-in-a-directory-recursive


```groovy
This code works for me:

import groovy.io.FileType

def list = []

def dir = new File("path_to_parent_dir")
dir.eachFileRecurse (FileType.FILES) { file ->
  list << file
}
Afterwards the list variable contains all files (java.io.File) of the given directory and its subdirectories:

list.each {
  println it.path
}
```