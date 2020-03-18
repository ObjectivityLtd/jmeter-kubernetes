#ensure env variable PAT_TOKEN is set first e.g.
#cd ~ && vi .bash_profile
#type: export PAT_TOKEN=...
#source .bash_profile
#Note: mnetwork-host is required because jmeter distributed testing works on rmi and creates backward connection to
#maven jmeter runnign within docker container

sudo docker run --network host --name gj21 -d -e AZP_URL=https://dev.azure.com/gstarczewski -e AZP_TOKEN=$PAT_TOKEN -e AZP_POOL=private -e AZP_AGENT_NAME=$(cat /etc/hostname) gabrielstar/jmeter:2.1
sudo docker cp .kube/  gj21:/root/