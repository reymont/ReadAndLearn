// https://github.com/jenkinsci/pipeline-examples/blob/master/pipeline-examples/parallel-from-list/parallelFromList.groovy

// While you can't use Groovy's .collect or similar methods currently, you can
// still transform a list into a set of actual build steps to be executed in
// parallel.

// Our initial list of strings we want to echo in parallel
def stepsForParallel = [:]

for (int i=0; i < 16; i++) {
    stepsForParallel[i] = transformIntoStep("echo i")
}

// Actually run the steps in parallel - parallel takes a map as an argument,
// hence the above.
parallel stepsForParallel

// Take the string and echo it.
def transformIntoStep(inputString) {
    // We need to wrap what we return in a Groovy closure, or else it's invoked
    // when this method is called, not when we pass it to parallel.
    // To do this, you need to wrap the code below in { }, and either return
    // that explicitly, or use { -> } syntax.
    return {
        node {
            echo inputString
        }
    }
}