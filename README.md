# Jmeter Cluster Support for Kubernetes

## Prerequisits

Kubernetes > 1.8


This solution was tested on k8 1.15.1 (Azure) and 1.17 (private cluster)

## TL;DR

### For private deployments

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

For Azure (CLI), edit azure-pipelines.1.azure.agent.kubernetes.sh and fill in details, then run:
```
echo "export pat=your_devops_org_PAT" > .bash_profile && source .bash_profile
cd ~ && rm -Rf jmeter-kubernetes && git clone https://github.com/ObjectivityLtd/jmeter-kubernetes && cd jmeter-kubernetes/pipelines/azure && chmod +x *.sh && ./azure-pipelines.1.azure.agent.kubernetes.sh jmeter-group
```


