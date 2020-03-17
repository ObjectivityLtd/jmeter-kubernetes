
#To test node, run this from same network:

./jmeter.sh -t examples/CSVSample.jmx -n -Jserver.rmi.ssl.disable=true -R10.1.137.110

#To test endpoints

curl -X GET http://10.1.137.110:5000/restart/apache-jmeter-5.2.1/1024m/3048m
curl -X GET http://10.1.137.110:5000/stop
