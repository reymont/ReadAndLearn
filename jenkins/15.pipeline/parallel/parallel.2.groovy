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
						pipeline {
                            agent any

                            stages{
                                steps {
                                    build_if_needed('aaa')
                                }
                            }
                        }
					},
					"secondTask" : {
						pipeline {
                            agent any

                            stages{
                                steps {
                                    build_if_needed('bbb')
                                }
                            }
                        }
					}
				)
			}
		}
	}
}