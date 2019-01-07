
# http://sdkman.io/install.html

curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk version
sdk selfupdate force

# https://gradle.org/install/#with-a-package-manager
sdk install gradle 4.4

# 

https://gradle.org/releases/
https://services.gradle.org/distributions/gradle-4.4-bin.zip
gradle -v
