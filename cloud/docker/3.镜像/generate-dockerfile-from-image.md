
* [repository - How to generate a Dockerfile from an image? - Stack Overflow ](https://stackoverflow.com/questions/19104847/how-to-generate-a-dockerfile-from-an-image)

To understand how a docker image was built, use the docker history --no-trunc command.

You can build a docker file from an image, but it will not contain everything you would want to fully understand how the image was generated. Reasonably what you can extract is the MAINTAINER, ENV, EXPOSE, VOLUME, WORKDIR, ENTRYPOINT, CMD, and ONBUILD parts of the dockerfile.

The following script should work for you:

#!/bin/bash
docker history --no-trunc "$1" | \
sed -n -e 's,.*/bin/sh -c #(nop) \(MAINTAINER .*[^ ]\) *0 B,\1,p' | \
head -1
docker inspect --format='{{range $e := .Config.Env}}
ENV {{$e}}
{{end}}{{range $e,$v := .Config.ExposedPorts}}
EXPOSE {{$e}}
{{end}}{{range $e,$v := .Config.Volumes}}
VOLUME {{$e}}
{{end}}{{with .Config.User}}USER {{.}}{{end}}
{{with .Config.WorkingDir}}WORKDIR {{.}}{{end}}
{{with .Config.Entrypoint}}ENTRYPOINT {{json .}}{{end}}
{{with .Config.Cmd}}CMD {{json .}}{{end}}
{{with .Config.OnBuild}}ONBUILD {{json .}}{{end}}' "$1"
I use this as part of a script to rebuild running containers as images: https://github.com/docbill/docker-scripts/blob/master/docker-rebase

The Dockerfile is mainly useful if you want to be able to repackage an image.

The thing to keep in mind, is a docker image can actually just be the tar backup of a real or virtual machine. I have made several docker images this way. Even the build history shows me importing a huge tar file as the first step in creating the image...

You can.

First way

$ docker pull centurylink/dockerfile-from-image
$ alias dfimage="docker run -v /var/run/docker.sock:/var/run/docker.sock --rm centurylink/dockerfile-from-image"
$ dfimage --help
Usage: dockerfile-from-image.rb [options] <image_id>
    -f, --full-tree                  Generate Dockerfile for all parent layers
    -h, --help                       Show this message
Here is the example to generate the Dockerfile from an exist image selenium/node-firefox-debug

core@core-01 ~ $ docker pull centurylink/dockerfile-from-image
core@core-01 ~ $ alias dfimage="docker run -v /var/run/docker.sock:/var/run/docker.sock --rm centurylink/dockerfile-from-image"
core@core-01 ~ $ dfimage selenium/node-firefox-debug
ADD file:b43bf069650bac07b66289f35bfdaf474b6b45cac843230a69391a3ee342a273 in /
RUN echo '#!/bin/sh' > /usr/sbin/policy-rc.d    && echo 'exit 101' >> /usr/sbin/policy-rc.d     && chmod +x /usr/sbin/policy-rc.d       && dpkg-divert --local --rename --add /sbin/initctl     && cp -a /usr/sbin/policy-rc.d /sbin/initctl    && sed -i 's/^exit.*/exit 0/' /sbin/initctl         && echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup         && echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean   && echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean   && echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean      && echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages      && echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes
RUN sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list
CMD ["/bin/bash"]
MAINTAINER Selenium <selenium-developers@googlegroups.com>
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe\n" > /etc/apt/sources.list && echo "deb http://archive.ubuntu.com/ubuntu trusty-updates main universe\n" >> /etc/apt/sources.list
RUN apt-get update -qqy && apt-get -qqy --no-install-recommends install ca-certificates openjdk-7-jre-headless unzip wget && rm -rf /var/lib/apt/lists/* && sed -i 's/\/dev\/urandom/\/dev\/.\/urandom/' ./usr/lib/jvm/java-7-openjdk-amd64/jre/lib/security/java.security
RUN mkdir -p /opt/selenium && wget --no-verbose http://selenium-release.storage.googleapis.com/2.46/selenium-server-standalone-2.46.0.jar -O /opt/selenium/selenium-server-standalone.jar
RUN sudo useradd seluser --shell /bin/bash --create-home && sudo usermod -a -G sudo seluser && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers && echo 'seluser:secret' | chpasswd
MAINTAINER Selenium <selenium-developers@googlegroups.com>
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true
ENV TZ=US/Pacific
RUN echo "US/Pacific" | sudo tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata
RUN apt-get update -qqy && apt-get -qqy install xvfb && rm -rf /var/lib/apt/lists/*
COPY file:335d2f6f9bfe311d2b38034ceab3b2ae2a1e07b9b203b330cac9857d6e17c148 in /opt/bin/entry_point.sh
RUN chmod +x /opt/bin/entry_point.sh
ENV SCREEN_WIDTH=1360
ENV SCREEN_HEIGHT=1020
ENV SCREEN_DEPTH=24
ENV DISPLAY=:99.0
USER [seluser]
CMD ["/opt/bin/entry_point.sh"]
MAINTAINER Selenium <selenium-developers@googlegroups.com>
USER [root]
RUN apt-get update -qqy && apt-get -qqy --no-install-recommends install firefox && rm -rf /var/lib/apt/lists/*
COPY file:52a2a815e3bb6b85c5adfbceaabb5665b63f63ef0fb0e3f774624ee399415f84 in /opt/selenium/config.json
USER [seluser]
MAINTAINER Selenium <selenium-developers@googlegroups.com>
USER [root]
RUN apt-get update -qqy && apt-get -qqy install x11vnc && rm -rf /var/lib/apt/lists/* && mkdir -p ~/.vnc && x11vnc -storepasswd secret ~/.vnc/passwd
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure --frontend noninteractive locales && apt-get update -qqy && apt-get -qqy --no-install-recommends install language-pack-en && rm -rf /var/lib/apt/lists/*
RUN apt-get update -qqy && apt-get -qqy --no-install-recommends install fonts-ipafont-gothic xfonts-100dpi xfonts-75dpi xfonts-cyrillic xfonts-scalable && rm -rf /var/lib/apt/lists/*
RUN apt-get update -qqy && apt-get -qqy install fluxbox && rm -rf /var/lib/apt/lists/*
COPY file:90e3a7f757c3df44d541b59234ad4ca996f799455eb8d426218619b244ebba68 in /opt/bin/entry_point.sh
RUN chmod +x /opt/bin/entry_point.sh
EXPOSE 5900/tcp
Another way, which you needn't pull the image to local and no command need be run.

Use above image as sample, you can get Dockerfile commands via below url:

https://imagelayers.io/?images=selenium%2Fnode-firefox-debug:latest

Wait for a while, there will be two windows, the up window lists the layers, the down window lists the command in Dockerfile

imagelayers.io screenshot

The URL format is:

https://imagelayers.io/?images=<USER>%2F<IMAGE>:<TAG>
In face, imagelayers.io is built by Centurylink