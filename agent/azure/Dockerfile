FROM ubuntu:16.04
LABEL maintainer="https://github.com/gabrielstar"
# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN apt-get update \
&& apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        git \
        mc \
        vim \
        iputils-ping \
        libcurl3 \
        libicu55 \
        libunwind8 \
        netcat

#Install higher maven version, jmeter plugin requires 3.5.0
RUN curl -o maven.tar.gz https://downloads.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz && \
    tar -zxvf maven.tar.gz && \
    mv apache-maven-3.6.3 /opt/maven

#if java install becomes problematic we can move it to pipeline with https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/tool/java-tool-installer?view=azure-devops
# This is in accordance to : https://www.digitalocean.com/community/tutorials/how-to-install-java-with-apt-get-on-ubuntu-16-04
RUN apt-get update && \
	apt-get install -y openjdk-8-jdk && \
	apt-get install -y ant && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/oracle-jdk8-installer;

# Fix certificate issues, found as of
# https://bugs.launchpad.net/ubuntu/+source/ca-certificates-java/+bug/983302
RUN apt-get update && \
	apt-get install -y ca-certificates-java && \
	apt-get clean && \
	update-ca-certificates -f && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/oracle-jdk8-installer;

#Install kubectl

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl


# Setup JAVA_HOME, this is useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
ENV JAVA_HOME_8_X64 /usr/lib/jvm/java-8-openjdk-amd64/
ENV M2_HOME /opt/maven
ENV PATH=${M2_HOME}/bin:${PATH}

WORKDIR /azp

COPY start.sh .
RUN chmod +x start.sh

CMD ["./start.sh"]
