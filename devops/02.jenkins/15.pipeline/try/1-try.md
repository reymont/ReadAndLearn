

# https://stackoverflow.com/questions/38392254/jenkins-pipeline-try-catch-insyde-a-retry-block/38403003

retry(2) {
    try {
        prepareEnvironment()
        setupBuildEnvironment() // sets up environment if it is not present yet
        runBuild()
    } catch (e) {
        echo 'Err: Incremental Build failed with Error: ' + e.toString()
        echo '     Trying to build with a clean Workspace'
        removeOldBuildEnvironment()
        throw e
    } finally {
        cleanupEnvironment()
    }
}