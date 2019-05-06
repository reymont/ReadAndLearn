

https://stackoverflow.com/questions/39958446/jenkins-parallel-pipeline-all-subroutine-calls-in-parameter-blocks-pass-argumen

It worked well in my case (Jenkins 2.7.4) to use method instead of closure:

def build_if_needed(project) {
  println "build_if_needed: $project"
  // ultimately this will kick off a build job...
}

parallel (
  aaa : { build_if_needed('aaa')},
  bbb : { build_if_needed('bbb')},
  ccc : { build_if_needed('ccc')},
  ddd : { build_if_needed('ddd')},
  eee : { build_if_needed('eee')}
)
In my experience, you should avoid using closures as much as you can in pipeline script. Jenkins seems to have problems to handle closures like https://issues.jenkins-ci.org/browse/JENKINS-26481.