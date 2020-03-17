#!/bin/bash

install_jmeter() {
  version=$1
  sudo apt install unzip
  sudo apt install openjdk-8-jre-headless
  curl -o ${version}.zip http://ftp.man.poznan.pl/apache//jmeter/binaries/${version}.zip
  unzip -o ${version}.zip
}

#install_jmeter apache-jmeter-5.2.1
version=$1
install_jmeter "$version"