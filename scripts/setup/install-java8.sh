echo "Installing java 8 for logstash..."
sudo apt-get --assume-yes install -y python-software-properties debconf-utils
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get --assume-yes update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
sudo apt-get --assume-yes install -y oracle-java8-installer
sudo apt-get --assume-yes install -y oracle-java8-set-default
