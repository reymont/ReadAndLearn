

https://jenkins.io/doc/tutorials/create-a-pipeline-in-blue-ocean/
https://github.com/jenkins-docs/creating-a-pipeline-in-blue-ocean


his tutorial shows you how to use the Blue Ocean feature of Jenkins to create a Pipeline that will orchestrate building a simple application.

Before starting this tutorial, it is recommended that you run through at least one of the initial set of tutorials from the Tutorials overview page first to familiarize yourself with CI/CD concepts (relevant to a technology stack you’re most familiar with) and how these concepts are implemented in Jenkins.

This tutorial uses the same application that the Build a Node.js and React app with npm tutorial is based on. Therefore, you’ll be building the same application although this time, completely through Blue Ocean. Since Blue Ocean provides a simplified Git-handling experience, you’ll be interacting directly with the repository on GitHub (as opposed to a local clone of this repository).

Duration: This tutorial takes 20-40 minutes to complete (assuming you’ve already met the prerequisites below). The exact duration will depend on the speed of your machine and whether or not you’ve already run Jenkins in Docker from another tutorial.

You can stop this tutorial at any point in time and continue from where you left off.

If you’ve already run though another tutorial, you can skip the Prerequisites and Run Jenkins in Docker sections below and proceed on to forking the sample repository. If you need to restart Jenkins, simply follow the restart instructions in Stopping and restarting Jenkins and then proceed on.

Prerequisites
For this tutorial, you will require:

A macOS, Linux or Windows machine with:
256 MB of RAM, although more than 512MB is recommended.
10 GB of drive space for Jenkins and your Docker images and containers.
The following software installed:
Docker - Read more about installing Docker in the Installing Docker section of the Installing Jenkins page.
Note: If you use Linux, this tutorial assumes that you are not running Docker commands as the root user, but instead with a single user account that also has access to the other tools used throughout this tutorial.
Run Jenkins in Docker
In this tutorial, you’ll be running Jenkins as a Docker container from the jenkinsci/blueocean Docker image.

To run Jenkins in Docker, follow the relevant instructions below for either macOS and Linux or Windows.

You can read more about Docker container and image concepts in the Docker and Downloading and running Jenkins in Docker sections of the Installing Jenkins page.

On macOS and Linux
Open up a terminal window.
Run the jenkinsci/blueocean image as a container in Docker using the following docker run command (bearing in mind that this command automatically downloads the image if this hasn’t been done):
docker run \
  --rm \
  -u root \
  -p 8080:8080 \
  -v jenkins-data:/var/jenkins_home \ 
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$HOME":/home \ 
  jenkinsci/blueocean
Maps the /var/jenkins_home directory in the container to the Docker volume with the name jenkins-data. If this volume does not exist, then this docker run command will automatically create the volume for you.
Maps the $HOME directory on the host (i.e. your local) machine (usually the /Users/<your-username> directory) to the /home directory in the container.
Note: If copying and pasting the command snippet above doesn’t work, try copying and pasting this annotation-free version here:

docker run \
  --rm \
  -u root \
  -p 8080:8080 \
  -v jenkins-data:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$HOME":/home \
  jenkinsci/blueocean
Proceed to the Setup wizard.
On Windows
Open up a command prompt window.
Run the jenkinsci/blueocean image as a container in Docker using the following docker run command (bearing in mind that this command automatically downloads the image if this hasn’t been done):
docker run ^
  --rm ^
  -u root ^
  -p 8080:8080 ^
  -v jenkins-data:/var/jenkins_home ^
  -v /var/run/docker.sock:/var/run/docker.sock ^
  -v "%HOMEPATH%":/home ^
  jenkinsci/blueocean
For an explanation of these options, refer to the macOS and Linux instructions above.

Proceed to the Setup wizard.
Accessing the Jenkins/Blue Ocean Docker container
If you have some experience with Docker and you wish or need to access the Jenkins/Blue Ocean Docker container through a terminal/command prompt using the docker exec command, you can add an option like --name jenkins-tutorials (with the docker run above), which would give the Jenkins/Blue Ocean Docker container the name "jenkins-tutorials".

This means you could access the Jenkins/Blue Ocean container (through a separate terminal/command prompt window) with a docker exec command like:

docker exec -it jenkins-tutorials bash

Setup wizard
Before you can access Jenkins, there are a few quick "one-off" steps you’ll need to perform.

Unlocking Jenkins
When you first access a new Jenkins instance, you are asked to unlock it using an automatically-generated password.

After the 2 sets of asterisks appear in the terminal/command prompt window, browse to http://localhost:8080 and wait until the Unlock Jenkins page appears.
Unlock Jenkins page

From your terminal/command prompt window again, copy the automatically-generated alphanumeric password (between the 2 sets of asterisks).
Copying initial admin password

On the Unlock Jenkins page, paste this password into the Administrator password field and click Continue.
Customizing Jenkins with plugins
After unlocking Jenkins, the Customize Jenkins page appears.

On this page, click Install suggested plugins.

The setup wizard shows the progression of Jenkins being configured and the suggested plugins being installed. This process may take a few minutes.

Creating the first administrator user
Finally, Jenkins asks you to create your first administrator user.

When the Create First Admin User page appears, specify your details in the respective fields and click Save and Finish.
When the Jenkins is ready page appears, click Start using Jenkins.
Notes:
This page may indicate Jenkins is almost ready! instead and if so, click Restart.
If the page doesn’t automatically refresh after a minute, use your web browser to refresh the page manually.
If required, log in to Jenkins with the credentials of the user you just created and you’re ready to start using Jenkins!
Stopping and restarting Jenkins
Throughout the remainder of this tutorial, you can stop the Jenkins/Blue Ocean Docker container by typing Ctrl-C in the terminal/command prompt window from which you ran the docker run ... command above.

To restart the Jenkins/Blue Ocean Docker container:

Run the same docker run ... command you ran for macOS, Linux or Windows above.
Note: This process also updates the jenkinsci/blueocean Docker image, if an updated one is available.
Browse to http://localhost:8080.
Wait until the log in page appears and log in.
Fork the sample repository on GitHub
Fork the simple "Welcome to React" Node.js and React application on GitHub into your own GitHub account.

Ensure you are signed in to your GitHub account. If you don’t yet have a GitHub account, sign up for a free one on the GitHub website.
Fork the creating-a-pipeline-in-blue-ocean on GitHub into your local GitHub account. If you need help with this process, refer to the Fork A Repo documentation on the GitHub website for more information.
Note: This is a different repository to the one used in the Build a Node.js and React app with npm tutorial. Although these repositories contain the same application code, ensure you fork and use the correct one before continuing on.
Create your Pipeline project in Blue Ocean
Go back to Jenkins and ensure you have accessed the Blue Ocean interface. To do this, make sure you:
have browsed to http://localhost:8080/blue and are logged in
or
have browsed to http://localhost:8080/, are logged in and have clicked Open Blue Ocean on the left.
In the Welcome to Jenkins box at the center of the Blue Ocean interface, click Create a new Pipeline to begin the Pipeline creation wizard.
Note: If you don’t see this box, click New Pipeline at the top right.
In Where do you store your code?, click GitHub.
In Connect to GitHub, click Create an access key here. This opens GitHub in a new browser tab.
Note: If you previously configured Blue Ocean to connect to GitHub using a personal access token, then Blue Ocean takes you directly to step 9 below.
In the new tab, sign in to your GitHub account (if necessary) and on the GitHub New Personal Access Token page, specify a brief Token description for your GitHub access token (e.g. Blue Ocean).
Note: An access token is usually an alphanumeric string that respresents your GitHub account along with permissions to access various GitHub features and areas through your GitHub account. This access token will have the appropriate permissions pre-selected, which Blue Ocean requires to access and interact with your GitHub account.
Scroll down to the end of the page (leaving all other Select scopes options with their default settings) and click Generate token.
On the resulting Personal access tokens page, copy your newly generated access token.
Back in Blue Ocean, paste the access token into the Your GitHub access token field and click Connect.
Connecting to GitHub
Jenkins now has access to your GitHub account (provided by your access token).

In Which organization does the repository belong to?, click your GitHub account (where you forked the repository above).
In Choose a repository, click your forked repository creating-a-pipeline-in-blue-ocean.
Click Create Pipeline.
Blue Ocean detects that there is no Jenkinsfile at the root level of the repository’s master branch and proceed to help you create one. (Therefore, you’ll need to click another Create Pipeline at the end of the page to proceed.)
Note: Under the hood, a Pipeline project created through Blue Ocean is actually "multibranch Pipeline". Therefore, Jenkins looks for the presence of at least one Jenkinsfile in any branch of your repository.
Create your initial Pipeline
Following on from creating your Pipeline project (above), in the Pipeline editor, select docker from the Agent dropdown in the Pipeline Settings panel on the right.
Initial to GitHub

In the Image and Args fields that appear, specify node:6-alpine and -p 3000:3000 respectively.
Configuring the agent
Note: For an explanation of these values, refer to annotations 1 and 2 of the Declarative Pipeline in the “Create your initial Pipeline…​” section of the Build a Node.js and React app tutorial.

Back in the main Pipeline editor, click the + icon, which opens the new stage panel on the right.
Add <em>Build</em> stage

In this panel, type Build in the Name your stage field and then click the Add Step button below, which opens the Choose step type panel.
Adding the Build stage

In this panel, click Shell Script near the top of the list (to choose that step type), which opens the Build / Shell Script panel, where you can enter this step’s values.
Choosing a step type
Tip: The most commonly used step types appear closest to the top of this list. To find other steps further down this list, you can filter this list using the Find steps by name option.

In the Build / Shell Script panel, specify npm install.
Specifying a shell step value
Note: For an explanation of this step, refer to annotation 4 of the Declarative Pipeline in the “Create your initial Pipeline…​” section of the Build a Node.js and React app tutorial.

( Optional ) Click the top-left back arrow icon Return from step icon to return to the main Pipeline editor.
Click the Save button at the top right to begin saving your new Pipeline with its "Build" stage.
In the Save Pipeline dialog box, specify the commit message in the Description field (e.g. Add initial Pipeline (Jenkinsfile)).
Save Pipeline dialog box

Leaving all other options as is, click Save & run and Jenkins proceeds to build your Pipeline.
When the main Blue Ocean interface appears, click the row to see Jenkins build your Pipeline project.
Note: You may need to wait several minutes for this first run to complete. During this time, Jenkins does the following:
Commits your Pipeline as a Jenkinsfile to the only branch (i.e. master) of your repository.
Initially queues the project to be built on the agent.
Downloads the Node Docker image and runs it in a container on Docker.
Executes the Build stage (defined in the Jenkinsfile) on the Node container. (During this time, npm downloads many dependencies necessary to run your Node.js and React application, which will ultimately be stored in the local node_modules directory within the Jenkins home directory).
Downloading <em>npm</em> dependencies

The Blue Ocean interface turns green if Jenkins built your application successfully.

Initial Pipeline runs successfully

Click the X at the top-right to return to the main Blue Ocean interface.
Main Blue Ocean interface
Note: Before continuing on, you can check that Jenkins has created a Jenkinsfile for you at the root of your forked GitHub repository (in the repository’s sole master branch).

Add a test stage to your Pipeline
From the main Blue Ocean interface, click Branches at the top-right to access your respository’s branches page, where you can access the master branch.
Repository branches page

Click the master branch’s "Edit Pipeline" icon Edit Pipeline on branch to open the Pipeline editor for this branch.
In the main Pipeline editor, click the + icon to the right of the Build stage you created above to open the new stage panel on the right.
Add <em>Test</em> stage

In this panel, type Test in the Name your stage field and then click the Add Step button below to open the Choose step type panel.
In this panel, click Shell Script near the top of the list.
In the resulting Test / Shell Script panel, specify ./jenkins/scripts/test.sh and then click the top-left back arrow icon Return from step icon to return to the Pipeline stage editor.
At the lower-right of the panel, click Settings to reveal this section of the panel.
Click the + icon at the right of the Environment heading (for which you’ll configure an environment directive).
In the Name and Value fields that appear, specify CI and true, respectively.
Environment directive
Note: For an explanation of this directive and its step, refer to annotations 1 and 3 of the Declarative Pipeline in the “Add a test stage…​” section of the Build a Node.js and React app tutorial.

( Optional ) Click the top-left back arrow icon Return from step icon to return to the main Pipeline editor.
Click the Save button at the top right to begin saving your Pipeline with with its new "Test" stage.
In the Save Pipeline dialog box, specify the commit message in the Description field (e.g. Add 'Test' stage).
Leaving all other options as is, click Save & run and Jenkins proceeds to build your amended Pipeline.
When the main Blue Ocean interface appears, click the top row to see Jenkins build your Pipeline project.
Note: You’ll notice from this run that Jenkins no longer needs to download the Node Docker image. Instead, Jenkins only needs to run a new container from the Node image downloaded previously. Therefore, running your Pipeline this subsequent time should be much faster.
If your amended Pipeline ran successfully, here’s what the Blue Ocean interface should look like. Notice the additional "Test" stage. You can click on the previous "Build" stage circle to access the output from that stage.
Test stage runs successfully (with output)

Click the X at the top-right to return to the main Blue Ocean interface.
Add a final deliver stage to your Pipeline
From the main Blue Ocean interface, click Branches at the top-right to access your respository’s master branch.
Click the master branch’s "Edit Pipeline" icon Edit Pipeline on branch to open the Pipeline editor for this branch.
In the main Pipeline editor, click the + icon to the right of the Test stage you created above to open the new stage panel.
Add <em>Deliver</em> stage

In this panel, type Deliver in the Name your stage field and then click the Add Step button below to open the Choose step type panel.
In this panel, click Shell Script near the top of the list.
In the resulting Deliver / Shell Script panel, specify ./jenkins/scripts/deliver.sh and then click the top-left back arrow icon Return from step icon to return to the Pipeline stage editor.
Add next step
Note: For an explanation of this step, refer to the deliver.sh file itself located in the jenkins/scripts of your forked repository on GitHub.

Click the Add Step button again.
In the Choose step type panel, type input into the Find steps by name field.
Choosing the input step type

Click the filtered Wait for interactive input step type.
In the resulting Deliver / Wait for interactive input panel, specify Finished using the web site? (Click "Proceed" to continue) in the Message field and then click the top-left back arrow icon Return from step icon to return to the Pipeline stage editor.
Specifying input step message value
Note: For an explanation of this step, refer to annotation 4 of the Declarative Pipeline in the “Add a final deliver stage…​” section of the Build a Node.js and React app tutorial.

Click the Add Step button (last time).
Click Shell Script near the top of the list.
In the resulting Deliver / Shell Script panel, specify ./jenkins/scripts/kill.sh.
Note: For an explanation of this step, refer to the kill.sh file itself located in the jenkins/scripts of your forked repository on GitHub.
( Optional ) Click the top-left back arrow icon Return from step icon to return to the main Pipeline editor.
Click the Save button at the top right to begin saving your Pipeline with with its new "Deliver" stage.
In the Save Pipeline dialog box, specify the commit message in the Description field (e.g. Add 'Deliver' stage).
Leaving all other options as is, click Save & run and Jenkins proceeds to build your amended Pipeline.
When the main Blue Ocean interface appears, click the top row to see Jenkins build your Pipeline project.
If your amended Pipeline ran successfully, here’s what the Blue Ocean interface should look like. Notice the additional "Deliver" stage. Click on the previous "Test" and "Build" stage circles to access the outputs from those stages.
Deliver stage pauses for user input

Ensure you are viewing the "Deliver" stage (click it if necessary), then click the green ./jenkins/scripts/deliver.sh step to expand its content and scroll down until you see the http://localhost:3000 link.
Deliver stage output only

Click the http://localhost:3000 link to view your Node.js and React application running (in development mode) in a new web browser tab. You should see a page/site with the title Welcome to React on it.
When you are finished viewing the page/site, click the Proceed button to complete the Pipeline’s execution.
Deliver stage runs successfully

Click the X at the top-right to return to the main Blue Ocean interface, which lists your previous Pipeline runs in reverse chronological order.
Main Blue Ocean interface with all previous runs displayed

Follow up (optional)
If you check the contents of the Jenkinsfile that Blue Ocean created at the root of your forked creating-a-pipeline-in-blue-ocean repository, notice the location of the environment directive. This directive’s location within the "Test" stage means that the environment variable CI (with its value of true) is only available within the scope of this "Test" stage.

You can set this directive in Blue Ocean so that its environment variable is available globally throughout Pipeline (as is the case in the Build a Node.js and React app with npm tutorial). To do this:

From the main Blue Ocean interface, click Branches at the top-right to access your respository’s master branch.
Click the master branch’s "Edit Pipeline" icon Edit Pipeline on branch to open the Pipeline editor for this branch.
In the main Pipeline editor, click the Test stage you created above to begin editing it.
In the stage panel on the right, click Settings to reveal this section of the panel.
Click the minus (-) icon at the right of the CI environment directive (you created earlier) to delete it.
Click the top-left back arrow icon Return from step icon to return to the main Pipeline editor.
In the Pipeline Settings panel, click the + icon at the right of the Environment heading (for which you’ll configure a global environment directive).
In the Name and Value fields that appear, specify CI and true, respectively.
Click the Save button at the top right to begin saving your Pipeline with with its relocated environment directive.
In the Save Pipeline dialog box, specify the commit message in the Description field (e.g. Make environment directive global).
Leaving all other options as is, click Save & run and Jenkins proceeds to build your amended Pipeline.
When the main Blue Ocean interface appears, click the top row to see Jenkins build your Pipeline project.
You should see the same build process you saw when you completed adding the final deliver stage (above). However, when you inspect the Jenkinsfile again, you’ll notice that the environment directive is now a sibling of the agent section.
Wrapping up
Well done! You’ve just used the Blue Ocean feature of Jenkins to build a simple Node.js and React application with npm!

The "Build", "Test" and "Deliver" stages you created above are the basis for building other applications in Jenkins with any technology stack, including more complex applications and ones that combine multiple technology stacks together.

Because Jenkins is extremely extensible, it can be modified and configured to handle practically any aspect of build orchestration and automation.

To learn more about what Jenkins can do, check out:

The Tutorials overview page for other introductory tutorials.
The User Handbook for more detailed information about using Jenkins, such as Pipelines (in particular Pipeline syntax) and the Blue Ocean interface.
The Jenkins blog for the latest events, other tutorials and updates.