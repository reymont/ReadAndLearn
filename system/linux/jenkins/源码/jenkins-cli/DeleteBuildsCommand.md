

hudson.cli.DeleteBuildsCommand

```java
build.delete();

```

hudson.model.Run
```java
    /**
     * Deletes this build and its entire log
     *
     * @throws IOException
     *      if we fail to delete.
     */
    public void delete() throws IOException {
        File rootDir = getRootDir();
        if (!rootDir.isDirectory()) {
            throw new IOException(this + ": " + rootDir + " looks to have already been deleted; siblings: " + Arrays.toString(project.getBuildDir().list()));
        }
        
        RunListener.fireDeleted(this);

        synchronized (this) { // avoid holding a lock while calling plugin impls of onDeleted
        File tmp = new File(rootDir.getParentFile(),'.'+rootDir.getName());
        
        if (tmp.exists()) {
            Util.deleteRecursive(tmp);
        }
        // TODO on Java 7 prefer: Files.move(rootDir.toPath(), tmp.toPath(), StandardCopyOption.ATOMIC_MOVE)
        boolean renamingSucceeded = rootDir.renameTo(tmp);
        Util.deleteRecursive(tmp);
        // some user reported that they see some left-over .xyz files in the workspace,
        // so just to make sure we've really deleted it, schedule the deletion on VM exit, too.
        if(tmp.exists())
            tmp.deleteOnExit();

        if(!renamingSucceeded)
            throw new IOException(rootDir+" is in use");
        LOGGER.log(FINE, "{0}: {1} successfully deleted", new Object[] {this, rootDir});

        removeRunFromParent();
        }
    }
```