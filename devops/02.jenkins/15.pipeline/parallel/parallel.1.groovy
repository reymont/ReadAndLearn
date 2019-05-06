def build_if_needed(project) {
  println "build_if_needed: $project"
}

pipeline {
    agent any

	stages{
		stage("Parallel") {
			steps {
				parallel (
					"firstTask" : {
						//do some stuff
						build_if_needed('aaa')
					},
					"secondTask" : {
						// Do some other stuff in parallel
						build_if_needed('bbb')
					}
				)
			}
		}
	}
}