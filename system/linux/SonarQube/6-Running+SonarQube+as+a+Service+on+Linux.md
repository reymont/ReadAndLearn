Running SonarQube as a Service on Linux - SonarQube Documentation - Doc SonarQube https://docs.sonarqube.org/display/SONAR/Running+SonarQube+as+a+Service+on+Linux


Running SonarQube as a Service on Linux
转至元数据结尾
由 David Racodon创建于八月 24, 2013 转至元数据起始
The following has been tested on Ubuntu 8.10 and CentOS 6.2.
Create the file /etc/init.d/sonar with this content:
#!/bin/sh
#
# rc file for SonarQube
#
# chkconfig: 345 96 10
# description: SonarQube system (www.sonarsource.org)
#
### BEGIN INIT INFO
# Provides: sonar
# Required-Start: $network
# Required-Stop: $network
# Default-Start: 3 4 5
# Default-Stop: 0 1 2 6
# Short-Description: SonarQube system (www.sonarsource.org)
# Description: SonarQube system (www.sonarsource.org)
### END INIT INFO
 
/usr/bin/sonar $*
Register SonarQube at boot time (Ubuntu, 32 bit):
sudo ln -s $SONAR_HOME/bin/linux-x86-32/sonar.sh /usr/bin/sonar
sudo chmod 755 /etc/init.d/sonar
sudo update-rc.d sonar defaults
Register SonarQube at boot time (RedHat, CentOS, 64 bit):
sudo ln -s $SONAR_HOME/bin/linux-x86-64/sonar.sh /usr/bin/sonar
sudo chmod 755 /etc/init.d/sonar
sudo chkconfig --add sonar