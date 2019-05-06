https://stackoverflow.com/questions/36872657/running-stages-in-parallel-with-jenkins-workflow-pipeline


You should do something like:

stage("Parallel") {
    steps {
        parallel (
            "firstTask" : {
                //do some stuff
            },
            "secondTask" : {
                // Do some other stuff in parallel
            }
        )
    }
}


Just to add the use of node here, to distribute jobs across multiple build servers/ VMs:

pipeline {
  stages {
    stage("Work 1"){
     steps{
      parallel ( "Build common Library":   
            {
              node('<Label>'){
                  /// your stuff
                  }
            },

        "Build Utilities" : {
            node('<Label>'){
               /// your stuff
              }
           }
         )
    }
}