

https://wiki.jenkins.io/display/JENKINS/Gogs+Webhook+Plugin

Created by sander v, last modified on Apr 10, 2017 Go to start of metadata
View Jenkins Gogs plugin on the plugin site for more information.
Allows users to use the Gogs Webhook
Gogs-Webhook Plugin
This plugin integrates Gogs to Jenkins.
In Gogs configure your webhook like this:
http(s)://<< jenkins-server >>/gogs-webhook/?job=<< jobname >>
Example how your the webhook in Gogs should look like:

Change Log
Version 1.0.10 (Apr 10, 2017)
Allow empty password [PR#19]
Version 1.0.9 (Mar 8, 2017)
Added new Gogs authentication but keeps it compatible with old version [PR#16]
Added folder support [PR#12]
Version 1.0.8 (Dec 20, 2016)
Fixes impersonation problem of v1.0.7
Version 1.0.7 (Dec 6, 2016)
Added Gogs secret per job [PR#3]
Version 1.0.6 (Sep 5, 2016)
Added pipeline support.
Version 1.0.4 (Jul 4, 2016)
Added CSRF protection [JENKINS-37149]
Version 1.0 (Jul 21, 2016)
First release
