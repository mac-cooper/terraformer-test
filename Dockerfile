FROM public.ecr.aws/amazonlinux/amazonlinux:latest as build

#Golang environment due to Terraformer's native language
ENV NAME=golang \
    GO_MAJOR_VERSION=1 \
    GO_MINOR_VERSION=17\
    GO_PATCH_VERSION=00 \
    CONTAINER_NAME="auto-sync"

ENV VERSION=$GO_MAJOR_VERSION.$GO_MINOR_VERSION.$GO_PATCH_VERSION \
    SUMMARY="Auto-Sync utilizes Terraformer to import Datadog resources into" \
    DESCRIPTION=" The use of auto-sync is to pull MBSRE verified monitors from Datadog\
Auto-Sync works with Datadog Monitor checker to ensure all parameters of a monitor meets standards. \
Auto-Sync will work on a schedule using the Rundeck Platform"

# Datadog Integration Auto Discovery
LABEL "com.datadoghq.ad.check_names"="auto-sync"
LABEL "com.datadoghq.ad.init_configs"="[{}"
LABEL "com.datadoghq.ad.instances"="[{"host": "%%host%%","port":"80"}]"

#Install dependencies

RUN \
rpm --rebuilddb && \
    yum update -y && \
    yum install -y \
 install java-1.8.0-openjdk-headless \
shadow-utils.x86_64 \
unzip \
wget \
    amazon-linux-extras \
    install epel \
findutils \
    python-setuptools \
awslogs \
    httpd \
    amazon-linux-extras install epel \
python3.7 \
python-setuptools \
    python3-pip \
golang \
which \
  # rm -rf /var/cache/yum/* \
  yum clean all

RUN groupadd -r rundeck
RUN useradd -r -u 1001 -g rundeck rundeck


#create non-root rundeck user to execute commands





#Terraform install
RUN wget https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_amd64.zip \
    && unzip terraform_0.13.5_linux_amd64.zip \
    && mv terraform /usr/local/bin


#Cloning of Terraformer repo
RUN git clone https://github.com/GoogleCloudPlatform/terraformer.git \
     && mv /terraformer /opt/terraformer

WORKDIR /opt/terraformer

#Creates terraformer binary as ./terraformer-datadog in /opt/terraformer folder which is deleted and ./terraformer binary os moves into auto-sync folder
RUN go mod download && go run build/main.go datadog \
    && mkdir /auto-sync \
    && mv ./terraformer-datadog /auto-sync/./terraformer-datadog \
    && rm -rf /opt/terraformer/

WORKDIR /auto-sync
RUN chmod 755 /auto-sync
COPY run.sh .
COPY init.tf .
RUN chmod 777 run.sh
RUN  terraform init

###### Multi Build 2
FROM public.ecr.aws/amazonlinux/amazonlinux:latest
COPY --from=build /auto-sync /auto-sync
WORKDIR /auto-sync

RUN chmod 755 /auto-sync
COPY . .
COPY run.sh .

RUN chmod 777 run.sh

RUN ["chmod", "+x", "./run.sh"]
CMD ["/bin/bash", "./run.sh"]
ENTRYPOINT ["/bin/bash", "./run.sh"]
VOLUME ["/home/mcooper"]
