#!/bin/bash


stop_jmeter_server() {
  killall "/usr/bin/java" || :
}

stop_jmeter_server