

Linux Java Service Wrapper Example 
http://www.jcgonzalez.com/linux-java-service-wrapper-example

This is a simple wrapper to run a Java program as service. You need to be a root user.

Intructions:

Create a file under  /etc/init.d/   with nano or vi and paste the example script below. ex.  sudo vi /etc/init.d/mytestserv
Modify the SERVICE_NAME, PATH_TO_JAR, and choose a PID_PATH_NAME for the file you are going to use to store your service ID.
Write the file and give execution permisions ex. sudo chmod +x /etc/init.d/mytestserv
Test that it runs ex. sudo service mytestserv start
Test that it stops ex. sudo service mytestserv stop
Test that it restarts ex. sudo service mytestserv restart

```sh
#!/bin/sh
SERVICE_NAME=MyService
PATH_TO_JAR=/usr/local/MyProject/MyJar.jar
PID_PATH_NAME=/tmp/MyService-pid
case $1 in
    start)
        echo "Starting $SERVICE_NAME ..."
        if [ ! -f $PID_PATH_NAME ]; then
            nohup java -jar $PATH_TO_JAR /tmp 2>> /dev/null >> /dev/null &
                        echo $! > $PID_PATH_NAME
            echo "$SERVICE_NAME started ..."
        else
            echo "$SERVICE_NAME is already running ..."
        fi
    ;;
    stop)
        if [ -f $PID_PATH_NAME ]; then
            PID=$(cat $PID_PATH_NAME);
            echo "$SERVICE_NAME stoping ..."
            kill $PID;
            echo "$SERVICE_NAME stopped ..."
            rm $PID_PATH_NAME
        else
            echo "$SERVICE_NAME is not running ..."
        fi
    ;;
    restart)
        if [ -f $PID_PATH_NAME ]; then
            PID=$(cat $PID_PATH_NAME);
            echo "$SERVICE_NAME stopping ...";
            kill $PID;
            echo "$SERVICE_NAME stopped ...";
            rm $PID_PATH_NAME
            echo "$SERVICE_NAME starting ..."
            nohup java -jar $PATH_TO_JAR /tmp 2>> /dev/null >> /dev/null &
                        echo $! > $PID_PATH_NAME
            echo "$SERVICE_NAME started ..."
        else
            echo "$SERVICE_NAME is not running ..."
        fi
    ;;
esac
```

Known Issues
Make sure your jar is not finishing execution by itself.
Use the nohup java -jar Myjar.jar & to verify that it can work as a service.
In Ubuntu use sudo update-rc.d mytestserv defaults if you want to run the service when the SO starts or sudo update-rc.d mytestserv disable to remove from startup.