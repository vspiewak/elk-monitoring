#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

ECHO_PREFIX="\e[1m\e[97m[\e[34mVagrant\e[97m]\e[0m"

echo -e "$ECHO_PREFIX Will work in /tmp"
cd /tmp

echo -e "$ECHO_PREFIX Set Europe/Paris as default timezone"
rm /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime

mkdir -p /etc/apt/sources.list.d

echo -e "$ECHO_PREFIX Add Elasticsearch APT repository"
wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
echo 'deb http://packages.elasticsearch.org/elasticsearch/1.3/debian stable main' >> /etc/apt/sources.list.d/elasticsearch.list

echo -e "$ECHO_PREFIX Add Logstash APT repository"
wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
echo 'deb http://packages.elasticsearch.org/logstash/1.4/debian stable main' >> /etc/apt/sources.list.d/logstash.list


echo -e "$ECHO_PREFIX Update APT packages index"
apt-get -qq update

echo -e "$ECHO_PREFIX Update APT system packages"
apt-get -y -qq upgrade

echo -e "$ECHO_PREFIX Install curl" 
apt-get -y -qq install curl

echo -e "$ECHO_PREFIX Download Sun JDK 8 x64"
curl -s -L -C - -b "oraclelicense=accept-securebackup-cookie" -O http://download.oracle.com/otn-pub/java/jdk/8u5-b13/jdk-8u5-linux-x64.tar.gz

echo -e "$ECHO_PREFIX Unzip JDK"
tar xzf jdk-8u5-linux-x64.tar.gz -C /opt
ln -s /opt/jdk1.8.0_05 /opt/jdk
rm -f jdk-8u5-linux-x64.tar.gz

echo -e "$ECHO_PREFIX Set as default java"
update-alternatives --install "/usr/bin/java" "java" "/opt/jdk/bin/java" 2000
update-alternatives --set java /opt/jdk/bin/java

update-alternatives --install "/usr/bin/javac" "javac" "/opt/jdk/bin/javac" 2000
update-alternatives --set javac /opt/jdk/bin/javac

echo -e "$ECHO_PREFIX Install Collectd"
apt-get -y -qq install collectd
update-rc.d collectd defaults

echo -e "$ECHO_PREFIX Configure Collectd"
cp /vagrant/collectd.conf /etc/collectd/

echo -e "$ECHO_PREFIX Restart Collectd"
/etc/init.d/collectd restart

echo -e "$ECHO_PREFIX Install NGiNX"
apt-get -y -qq install nginx
update-rc.d nginx defaults

echo -e "$ECHO_PREFIX Restart NGiNX"
/etc/init.d/nginx restart

echo -e "$ECHO_PREFIX Install Kibana"
curl -O https://download.elasticsearch.org/kibana/kibana/kibana-3.1.0.tar.gz
tar xzf kibana-3.1.0.tar.gz
mv kibana-3.1.0 /usr/share/nginx/www/kibana
rm kibana-3.1.0.tar.gz

echo -e "$ECHO_PREFIX Configure Kibana"
cp /vagrant/kibana.config.js /usr/share/nginx/www/kibana/config.js

echo -e "$ECHO_PREFIX Install dashboards"
cp /vagrant/dashboard.collectd.json /usr/share/nginx/www/kibana/app/dashboards/collectd.json
cp /vagrant/dashboard.system.json /usr/share/nginx/www/kibana/app/dashboards/system.json

echo -e "$ECHO_PREFIX Install Elasticsearch"
apt-get -y -qq install elasticsearch
update-rc.d elasticsearch defaults 95 10

echo -e "$ECHO_PREFIX Configure Elasticsearch"
echo 'JDK_DIRS="/opt/jdk"' >> /etc/default/elasticsearch
echo 'JAVA_HOME="/opt/jdk"' >> /etc/default/elasticsearch
#echo 'ES_HEAP_SIZE=1g' >> /etc/default/elasticsearch

echo -e "$ECHO_PREFIX Install Elasticsearch head plugin"
/usr/share/elasticsearch/bin/plugin -s -i mobz/elasticsearch-head

echo -e "$ECHO_PREFIX Install Elasticsearch paramedic plugin"
/usr/share/elasticsearch/bin/plugin -s -i karmi/elasticsearch-paramedic

echo -e "$ECHO_PREFIX Install Elasticsearch kopf plugin"
/usr/share/elasticsearch/bin/plugin -s -i lmenezes/elasticsearch-kopf

echo -e "$ECHO_PREFIX Install Elasticsearch HQ plugin"
/usr/share/elasticsearch/bin/plugin -s -i royrusso/elasticsearch-HQ

echo -e "$ECHO_PREFIX Install Elasticsearch bigdesk plugin"
/usr/share/elasticsearch/bin/plugin -s -i lukas-vlcek/bigdesk

echo -e "$ECHO_PREFIX Start Elasticsearch"
/etc/init.d/elasticsearch restart

echo -e "$ECHO_PREFIX Install Logstash"
apt-get -y install logstash
update-rc.d logstash defaults

echo -e "$ECHO_PREFIX Configure Logstash"
cp /vagrant/logstash.conf /etc/logstash/conf.d/

echo -e "$ECHO_PREFIX Start Logstash"
/etc/init.d/logstash restart
