https://stackoverflow.com/questions/13052390/jenkins-remove-old-builds-with-command-line


It looks like this has been added to the CLI, or is at least being worked on: http://jenkins.361315.n4.nabble.com/How-to-purge-old-builds-td385290.html

Syntax would be something like this: java -jar jenkins-cli.jar -s http://my.jenkins.host delete-builds myproject '1-7499' --username $user --password $password


Here is another option: delete the builds remotely with cURL. (Replace the beginning of the URLs with whatever you use to access Jenkins with your browser.)

$ curl -X POST http://jenkins-host.tld:8080/jenkins/job/myJob/[1-56]/doDeleteAll
The above deletes build #1 to #56 for job myJob.

If authentication is enabled on the Jenkins instance, a user name and API token must be provided like this:

$ curl -u userName:apiToken -X POST http://jenkins-host.tld:8080/jenkins/job/myJob/[1-56]/doDeleteAll
The API token must be fetched from the /me/configure page in Jenkins. Just click on the "Show API Token..." button to display both the user name and the API token.

Edit: As pointed out by yegeniy in a comment below, one might have to replace doDeleteAll by doDelete in the URLs above to make this work, depending on the configuration.