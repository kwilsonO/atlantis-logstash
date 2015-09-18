echo "Installing java 8 for logstash..."
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get --assume-yes update
sudo apt-get --assume-yes install oracle-java8-installer
sudo apt-get --assume-yes install oracle-java8-set-default
