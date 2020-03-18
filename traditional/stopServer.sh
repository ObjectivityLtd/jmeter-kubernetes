#!/bin/bash


stop_jmeter_server() {
   kill -9 $(cat jmeter.pid)  || :
}

stop_jmeter_server