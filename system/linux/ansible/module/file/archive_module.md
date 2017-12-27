

# http://docs.ansible.com/ansible/latest/archive_module.html


```yml
# Compress directory /path/to/foo/ into /path/to/foo.tgz
- archive:
    path: /path/to/foo
    dest: /path/to/foo.tgz

# Compress regular file /path/to/foo into /path/to/foo.gz and remove it
- archive:
    path: /path/to/foo
    remove: True

# Create a zip archive of /path/to/foo
- archive:
    path: /path/to/foo
    format: zip

# Create a bz2 archive of multiple files, rooted at /path
- archive:
    path:
        - /path/to/foo
        - /path/wong/foo
    dest: /path/file.tar.bz2
    format: bz2

# Create a bz2 archive of a globbed path, while excluding specific dirnames - archive:
    path:
        - /path/to/foo/*
    dest: /path/file.tar.bz2
    exclude_path:
        - /path/to/foo/bar
        - /path/to/foo/baz
    format: bz2

# Create a bz2 archive of a globbed path, while excluding a glob of dirnames
    path:
        - /path/to/foo/*
    dest: /path/file.tar.bz2
    exclude_path:
        - /path/to/foo/ba*
    format: bz2
```