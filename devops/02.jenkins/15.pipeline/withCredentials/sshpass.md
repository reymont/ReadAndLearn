
# https://pkgs.org/download/sshpass
sudo apt-get update ; sudo apt-get install sshpass
yum install sshpass
# https://stackoverflow.com/questions/37805901/jenkins-pipeline-sshagent-remote-ssh
node {
    stage 'Does sshpass work?'
    sh 'sshpass -p \'password\' ssh user@host "ls; hostname; whois google.com;"'
}