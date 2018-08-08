

# Implemented Steps

## File System

findFiles - Find/list files in the workspace. Returns an array of FileWrappers (help)
touch - Create a file (if not already exist) in the workspace, and set the timestamp. Returns a FileWrapper representing the file that was touched. (help)
sha1 - Computes the SHA1 of a given file. (help)

## Zip Files

zip - Create Zip file. (help)
unzip - Extract/Read Zip file (help)

## Configuration Files

readProperties - Read java properties from files in the workspace or text. (help)
readManifest - Read a Jar Manifest. (help)
readYaml - Read YAML from files in the workspace or text. (help)
writeYaml - Write a YAML file from an object. (help)
readJSON - Read JSON from files in the workspace or text. (help)
writeJSON - Write a JSON object to a files in the workspace. (help)

## Maven Projects

readMavenPom - Read a Maven Project into a Model data structure. (help)
writeMavenPom - Write a Model data structure to a file. (help)