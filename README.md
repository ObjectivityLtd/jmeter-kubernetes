# Azure JMeter Architectures & approaches
# Jmeter Azure pipelines examples

This repo contains 4 examples of pipelines that execute performance tests in Azure Cloud.

pipelines/
 - azure-pipelines.0.private.agent.kubernetes.yml - pipelines run against private agent using private k8 cluster
 - azure-pipelines.0.private.agent.maven.distributed.traditional.yml - pipelines run against private agent using traditional JMeter grid deployment, with maven
 - azure-pipelines.0.private.agent.maven.yml - pipeline run against private agent, no distributed tests,  with maven
 - azure-pipelines.1.azure.agent.kubernetes.yaml - run against azure build agent against azure aks k8 cluster deployment


jmeter/
 - as_jmx - contains plain jmx scenario
 - as_maven - contains jmeter tests as maven projects

agent/
 - contains Dockerfile for private build agent and run instructions

artifactory/
 - start script for Artifactory that can store reports as artifacts, that is used in private k8 deployment

kubernetes/
 - bin - contains bash shell scripts for running various k8 and azure pipeline automation tasks
 - config - contains original Dockerfles and k8 config maps and deployment files
 - tmp - temp dir

traditional/
  - contains scripts to set up traditional JMeter cluster and control it via REST calls with flask end-points



## Prerequisites

Kubernetes > 1.8


Kubernetes architectures were tested on k8 1.15.1 (Azure) and 1.17 (private cluster)

## How to set-up Kubernetes clusters ?

For pipelines that require Kubernetes service you need to create one first either via Azure AKS or locally. Once you have cluster up and running ..

### For private deployments run

k8 1.16 and below
```bash
./dockerimages.sh
./jmeter_cluster_create.sh
./dashboard.sh
./start_test.sh
```
k8 1.17 and higher

```bash
./dockerimages.sh
./jmeter_cluster_create_v17.sh
./dashboard.sh
./start_test.sh
```

For Azure deployments from AKS service (CLI), edit azure-pipelines.1.azure.agent.kubernetes.sh and fill in details, then run:
```
echo "export pat=your_devops_org_PAT" > .bash_profile
cd ~ && source .bash_profile && rm -Rf jmeter-kubernetes && git clone https://github.com/ObjectivityLtd/jmeter-kubernetes && cd jmeter-kubernetes/pipelines/azure && chmod +x *.sh && ./azure-pipelines.1.azure.agent.kubernetes.sh jmeter-group
```

- Visit this project Wiki for detailed description of each pipeline and use-case.
- Visit: https://medium.com/@gabriel.starczewski/jmeter-and-azure-pipelines-55f0594239ac to understand how to run Jmeter tests on Azure without Kubernetes cluster.

Credit:The kubernetes base solution is based on kubernautes team repo and articles.
