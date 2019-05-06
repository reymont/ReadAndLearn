

https://stackoverflow.com/questions/19523063/zip-utility-giving-me-different-md5sum-every-time-in-linux

The archive being generated does not only contain the compressed file data, but also "`extra file attributes`" (as refered in zip documentation), as file timestamps, file attributes, ...

If this metadata is different between compressions, you will never get the same checksum, as the metadata for the compresed file has changed and has been included in the archive.

You can use zip's -X option (or the long --no-extra option) to avoid including the files extra attributes in the archive:

`zip -X foo.zip foo-file`

Sucessive runs of this command without file modifications must not change the hash of the archive.