APT_UPDATED="True"

CURL_INSTALLED=$(dpkg -l | grep " curl ")
if [ -z  "$CURL_INSTALLED" ]
then
    if [ -z $APT_UPDATED ]
    then
        sudo apt-get update
        APT_UPDATED="True"
    fi
    sudo apt-get -y install curl
fi

RUBY_INSTALLED=$(dpkg -l | grep " ruby2.0 ")
if [ -z  "$RUBY_INSTALLED" ]
then
    if [ -z $APT_UPDATED ]
    then
        sudo apt-get update
        APT_UPDATED="True"
    fi
    sudo apt-get -y install ruby2.0 ruby2.0-dev
fi

BUNDLER_INSTALLED=$(dpkg -l | grep " bundler ")
if [ -z  "$BUNDLER_INSTALLED" ]
then
    if [ -z $APT_UPDATED ]
    then
        sudo apt-get update
        APT_UPDATED="True"
    fi
    sudo apt-get -y install bundler
fi

RDOC_INSTALLED=$(gem2.0 list --local | grep "^rdoc ")
if [ -z  "$BUNDLER_INSTALLED" ]
then
    sudo gem2.0 install rdoc
fi

NTP_INSTALLED=$(dpkg -l | grep " ntp ")
if [ -z  "$NTP_INSTALLED" ]
then
    if [ -z $APT_UPDATED ]
    then
        sudo apt-get update
        APT_UPDATED="True"
    fi
    sudo apt-get -y install ntp
fi

JAVA_INSTALLED=$(which java)
if [ -z  "$JAVA_INSTALLED" ]
then
    if [ -z "$APT_UPDATED" ]
    then
        sudo apt-get update
        APT_UPDATED="True"
    fi
    sudo apt-get -y install openjdk-7-jre
fi
