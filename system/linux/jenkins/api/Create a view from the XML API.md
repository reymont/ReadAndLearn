

* [[JENKINS-8927] Create a view from the XML API - Jenkins JIRA ](https://issues.jenkins-ci.org/browse/JENKINS-8927)

It's not possible to create a view from the API, since the views are part of the Hudson config.xml itself, it seems that the createItem URL doesn't match the need as it looks designed to create the new config.xml for a dedicated job.
The REST API could be some thing like:
GET http://myserver:8080/view (All views)
GET http://myserver:8080/view/myView (switch to Specific view - myView)
POST http://myserver:8080/view (Create new view as defined in the posted XML)

GET http://myserver:8080/view/myView/config.xml