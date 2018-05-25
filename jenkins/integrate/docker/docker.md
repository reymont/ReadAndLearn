


# jenkins 2.46.2

192.168.31.251
/usr/local/jenkins

```dockerfile
FROM jenkins:2.46.2

# RUN apt-get install -y git subversion

ADD docker /usr/bin/docker
ADD apache-maven-3.3.9-bin.tar.gz /usr/local/
ADD sonar-scanner-2.8.tar.gz /usr/local/
# ADD jenkins_home.zip  /usr/share/jenkins/
#ADD plugins.tar.gz /usr/share/jenkins/ref
ADD ref.tar.gz /usr/share/jenkins/

ENV MAVEN_HOME /usr/local/apache-maven-3.3.9
ENV SONARSCANNER_HOME=/usr/local/sonar-scanner-2.8
ENV PATH "$PATH:$MAVEN_HOME/bin:$SONARSCANNER_HOME/bin"

```

# jenkins 2.46.1

192.168.31.251
/usr/local/2.46.1

```dockerfile
FROM docker.yihecloud.com/base/java:2.0

RUN rm -rf /var/lib/apt/lists/*

ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_SLAVE_AGENT_PORT 50000
ENV JENKINS_OPTS --httpPort=8080 --prefix=/jenkins --argumentsRealm.passwd.jenkins=jenkins --argumentsRealm.roles.jenkins=admin

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container, 
# ensure you use the same uid
RUN groupadd -g ${gid} ${group} \
    && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

# Jenkins home directory is a volume, so configuration and build history 
# can be persisted and survive image upgrades
VOLUME /var/jenkins_home

# `/usr/share/jenkins/ref/` contains all reference configuration we want 
# to set on a fresh new installation. Use it to bundle additional plugins 
# or config file with your custom jenkins Docker image.
RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d

ENV TINI_SHA afbf8de8a63ce8e4f18cb3f34dfdbbd354af68a1
  
COPY tini-static-amd64 /bin/tini
RUN chmod +x /bin/tini && echo "$TINI_SHA  /bin/tini" | sha1sum -c -

COPY docker /bin/docker
RUN chmod +x /bin/docker

COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy

# jenkins version being bundled in this docker image
ARG JENKINS_VERSION
ENV JENKINS_VERSION ${JENKINS_VERSION:-3.0.0}

COPY jenkins.war /usr/share/jenkins/jenkins.war

ENV JENKINS_UC https://updates.jenkins.io
RUN chown -R ${user} "$JENKINS_HOME" /usr/share/jenkins/ref /usr/local/bin/

# for main web interface:
EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

USER ${user}

COPY jenkins-support /usr/local/bin/jenkins-support
COPY jenkins.sh /usr/local/bin/jenkins.sh 
ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]


USER root
# from a derived Dockerfile, can use `RUN plugins.sh active.txt` to setup /usr/share/jenkins/ref/plugins from a support bundle
COPY plugins.sh /usr/local/bin/plugins.sh
COPY install-plugins.sh /usr/local/bin/install-plugins.sh
# COPY plugins.zip /usr/share/jenkins/ref
# RUN cd /usr/share/jenkins/ref && unzip plugins.zip && rm -f plugins.zip 
COPY jenkins_home.zip  /usr/share/jenkins/
RUN cd /usr/share/jenkins/ && unzip -o jenkins_home.zip && rm -f jenkins_home.zip && rm -rf ref && mv jenkins_home ref && chmod 777 ref

# install maven and some other tools
RUN mkdir -p /usr/share/tools
COPY apache-maven-3.3.9-bin.tar.gz /usr/share/tools/
COPY sonar-scanner-2.8.zip /usr/share/tools/
RUN cd  /usr/share/tools && tar -zxvf apache-maven-3.3.9-bin.tar.gz && unzip sonar-scanner-2.8.zip && rm -f apache-maven-3.3.9-bin.tar.gz && rm -f sonar-scanner-2.8.zip
ENV MAVEN_HOME /usr/share/tools/apache-maven-3.3.9/bin 
ENV SONARSCANNER_HOME=/usr/share/tools/sonar-scanner-2.8/bin
ENV PATH "${PATH}:${MAVEN_HOME}:${SONARSCANNER_HOME}" 
RUN yum -y install git
RUN yum -y install subversion
USER ${user}

```