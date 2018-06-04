

Running Java Applications as a Linux Service – :: if you never try you never know :: 
https://adisembiring.wordpress.com/2011/04/04/running-java-applications-as-a-linux-service/
windows - How to install a Java application as a service - Stack Overflow 
https://stackoverflow.com/questions/7352291/how-to-install-a-java-application-as-a-service/7352350#7352350


I use Java Service Wrapper to install as windows or linux service: http://wrapper.tanukisoftware.com/doc/english/download.jsp

~> create one runnable JAR to your app.

~> Download the proper service wrapper (they are diffrent to windows and linux)

~> Configure the service in wrapper.conf

Important: set wrapper.java.classpath correct (your jar must be here too) Set wrapper.java.mainclass with org.tanukisoftware.wrapper.WrapperSimpleApp
Set wrapper.app.parameter.1 with the name of your main class, for example:

wrapper.app.parameter.1=Main
~> Test the service as console (windows bat)