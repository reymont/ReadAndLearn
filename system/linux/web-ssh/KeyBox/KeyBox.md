

skavanagh/KeyBox: KeyBox is a web-based SSH console that centrally manages administrative access to systems. Web-based administration is combined with management and distribution of user's public SSH keys. 
https://github.com/skavanagh/KeyBox

KeyBox

KeyBox is a web-based SSH console that centrally manages administrative access to systems. Web-based administration is combined with management and distribution of user's public SSH keys. Key management and administration is based on profiles assigned to defined users.

Administrators can login using two-factor authentication with FreeOTP or Google Authenticator. From there they can manage their public SSH keys or connect to their systems through a web-shell. Commands can be shared across shells to make patching easier and eliminate redundant command execution.

KeyBox layers TLS/SSL on top of SSH and acts as a bastion host for administration. Protocols are stacked (TLS/SSL + SSH) so infrastructure cannot be exposed through tunneling / port forwarding. More details can be found in the following whitepaper: The Security Implications of SSH. Also, SSH key management is enabled by default to prevent unmanaged public keys and enforce best practices.

Terminals

AMI in the AWS Marketplace

If you are using AWS, the simplest way to get started is to run the AMI from the AWS marketplace.

http://aws.amazon.com/marketplace/pp/B076PNFPCL

Once the KeyBox instance is up and running, open your browser to https://<EC2 Instance IP>:443

Login with

username:admin 
password:<Instance ID>
In order to help register new EC2 instances, the KeyBox public can be found under 'Settings -> Public Key' and should be imported as an EC2 Key Pair in the AWS console.

Prerequisites

Java JDK 1.8 or greater http://www.oracle.com/technetwork/java/javase/downloads/index.html

Browser with Web Socket support http://caniuse.com/websockets (Note: In Safari if using a self-signed certificate you must import the certificate into your Keychain. Select 'Show Certificate' -> 'Always Trust' when prompted in Safari)

Maven 3 or greater http://maven.apache.org (Only needed if building from source)

Install FreeOTP or Google Authenticator to enable two-factor authentication with Android or iOS

Application	Android	iOS
FreeOTP	Google Play	iTunes
Google Authenticator	Google Play	iTunes
To Run Bundled with Jetty

Download keybox-jetty-vXX.XX.tar.gz

https://github.com/skavanagh/KeyBox/releases

Export environment variables

for Linux/Unix/OSX

 export JAVA_HOME=/path/to/jdk
 export PATH=$JAVA_HOME/bin:$PATH
for Windows

 set JAVA_HOME=C:\path\to\jdk
 set PATH=%JAVA_HOME%\bin;%PATH%
Start KeyBox

for Linux/Unix/OSX

    ./startKeyBox.sh
for Windows

    startKeyBox.bat
How to Configure SSL in Jetty (it is a good idea to add or generate your own unique certificate)

http://www.eclipse.org/jetty/documentation/current/configuring-ssl.html

To Build from Source

Export environment variables

export JAVA_HOME=/path/to/jdk
export M2_HOME=/path/to/maven
export PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH
In the directory that contains the pom.xml run

mvn package jetty:run
Note: Doing a mvn clean will delete the H2 DB and wipe out all the data.

Using KeyBox

Open browser to https://<whatever ip>:8443

Login with

username:admin
password:changeme
Note: When using the AMI instance, the password is defaulted to the <Instance ID>. Also, the AMI uses port 443 as in https://<Instance IP>:443

Steps:

Create systems
Create profiles
Assign systems to profile
Assign profiles to users
Users can login to create sessions on assigned systems
Start a composite SSH session or create and execute a script across multiple sessions
Add additional public keys to systems
Disable any administrative public key forcing key rotation.
Audit session history
Managing SSH Keys

By default KeyBox will overwrite all values in the specified authorized_keys file for a system. You can disable key management by editing KeyBoxConfig.properties file and use KeyBox only as a bastion host. This file is located in the jetty/keybox/WEB-INF/classes directory. (or the src/main/resources directory if building from source)

#set to false to disable key management. If false, the KeyBox public key will be appended to the authorized_keys file (instead of it being overwritten completely).
keyManagementEnabled=false
Also, the authorized_keys file is updated/refreshed periodically based on the relationships defined in the application. If key management is enabled the refresh interval can be specified in the KeyBoxConfig.properties file.

#authorized_keys refresh interval in minutes (no refresh for <=0)
authKeysRefreshInterval=120
By default KeyBox will generated and distribute the SSH keys managed by administrators while having them download the generated private. This forces admins to use strong passphrases for keys that are set on systems. The private key is only available for download once and is not stored on the application side. To disable and allow administrators to set any public key edit the KeyBoxConfig.properties.

#set to true to generate keys when added/managed by users and enforce strong passphrases set to false to allow users to set their own public key
forceUserKeyGeneration=false
Supplying a Custom SSH Key Pair

KeyBox generates its own public/private SSH key upon initial startup for use when registering systems. You can specify a custom SSH key pair in the KeyBoxConfig.properties file.

For example:

#set to true to regenerate and import SSH keys  --set to true
resetApplicationSSHKey=true

#SSH Key Type 'dsa' or 'rsa'
sshKeyType=rsa

#private key  --set pvt key
privateKey=/Users/kavanagh/.ssh/id_rsa

#public key  --set pub key
publicKey=/Users/kavanagh/.ssh/id_rsa.pub

#default passphrase  --leave blank if passphrase is empty
defaultSSHPassphrase=myPa$$w0rd
After startup and once the key has been registered it can then be removed from the system. The passphrase and the key paths will be removed from the configuration file.

Adjusting Database Settings

Database settings can be adjusted in the configuration properties.

#Database user
dbUser=keybox
#Database password
dbPassword=p@$$w0rd!!
#Database JDBC driver
dbDriver=org.h2.Driver
#Connection URL to the DB
dbConnectionURL=jdbc:h2:keydb/keybox;CIPHER=AES;
By default the datastore is set as embedded, but a remote H2 database can supported through adjusting the connection URL.

#Connection URL to the DB
dbConnectionURL=jdbc:h2:tcp://<host>:<port>/~/keybox;CIPHER=AES;
External Authentication

External Authentication can be enabled through the KeyBoxConfig.properties.

For example:

#specify a external authentication module (ex: ldap-ol, ldap-ad).  Edit the jaas.conf to set connection details
jaasModule=ldap-ol
Connection details need to be set in the jaas.conf file

ldap-ol {
	com.sun.security.auth.module.LdapLoginModule SUFFICIENT
	userProvider="ldap://hostname:389/ou=example,dc=keybox,dc=com"
	userFilter="(&(uid={USERNAME})(objectClass=inetOrgPerson))"
	authzIdentity="{cn}"
	useSSL=false
	debug=false;
};
Administrators will be added as they are authenticated and profiles of systems may be assigned by full-privileged users.

User LDAP roles can be mapped to profiles defined in KeyBox through the use of the org.eclipse.jetty.jaas.spi.LdapLoginModule.

ldap-ol-with-roles {
    //openldap auth with roles that can map to profiles
    org.eclipse.jetty.jaas.spi.LdapLoginModule required
    debug="false"
    useLdaps="false"
    contextFactory="com.sun.jndi.ldap.LdapCtxFactory"
    hostname="<SERVER>"
    port="389"
    bindDn="<BIND-DN>"
    bindPassword="<BIND-DN PASSWORD>"
    authenticationMethod="simple"
    forceBindingLogin="true"
    userBaseDn="ou=users,dc=keybox,dc=com"
    userRdnAttribute="uid"
    userIdAttribute="uid"
    userPasswordAttribute="userPassword"
    userObjectClass="inetOrgPerson"
    roleBaseDn="ou=groups,dc=keybox,dc=com"
    roleNameAttribute="cn"
    roleMemberAttribute="member"
    roleObjectClass="groupOfNames";
};
Users will be added/removed from defined profiles as they login and when the role name matches the profile name.

Auditing

Auditing is disabled by default and is only a proof of concept. Can be enabled in the KeyBoxConfig.properties.

#enable audit  --set to true to enable
enableInternalAudit=true
Screenshots

Login

Two-Factor

More Terminals

Manage Systems

Manage Users

Define SSH Keys

Disable SSH Keys

Acknowledgments

Special thanks goes to these amazing projects which makes this (and other great projects) possible.

JSch Java Secure Channel - by ymnk
term.js A terminal written in javascript - by chjj
Third-party dependencies are mentioned in the 3rdPartyLicenses.md

Author

Sean Kavanagh

sean.p.kavanagh6@gmail.com
https://twitter.com/spkavanagh6
(Follow me on twitter for release updates, but mostly nonsense)

Donate

Dontations are always welcome!