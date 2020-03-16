#!/bin/bash
sudo apt install unzip
sudo apt install openjdk-8-jre-headless
version=apache-jmeter-5.2.1
curl -o ${version}.zip  http://ftp.man.poznan.pl/apache//jmeter/binaries/${version}.zip
unzip ${version}.zip
cd ${version}/bin
HEAP="-Xms512m -Xmx3G"
./jmeter-server -Jserver.rmi.ssl.disable=true &
