

# jenkins - How to configure Git post commit hook - Stack Overflow 
https://stackoverflow.com/questions/12794568/how-to-configure-git-post-commit-hook


# Hook doesn't work when CSRF is enabled · Issue #385 · jenkinsci/gitlab-plugin 
https://github.com/jenkinsci/gitlab-plugin/issues/385


You are using the wrong URL. `/project/TestCiWorkflowProduction` would be the correct one for your case. The URL mentioned by you is an internal URL of the Jenkins and has nothing to do with this plugin.

# Not working with Jenkins 2.0 Pipeline plugin · Issue #31 · jenkinsci/gitlab-hook-plugin 
https://github.com/jenkinsci/gitlab-hook-plugin/issues/31

Unable to trigger Pipeline Project build on Jenkins 2.7, Pipeline Plugin 2.2, GitLab 7.7.
Jenkins log: No valid crumb was included in request for /github-webhook/. Returning 403.

Tried these URLs, but in vain:

http://your-jenkins-server/gitlab/build_now
http://your-jenkins-server/gitlab/build_now/project_name
Freestyle project builds fine though.

Note: Disabled Cross Site Forgery security on Jenkins to make it working. Unchecked Manage Jenkins > Configure Global Security > Prevent Cross Site Request Forgery exploits on Jenkins.


I used this URL and it works: http://jenkins host:port/project/my job name