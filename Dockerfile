FROM ubuntu:21.10
WORKDIR /app
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y

RUN apt install -y apt-utils git curl wget

RUN apt install -y bzip2 file gzip gnupg unzip

RUN apt install -y musl-dev openssh-server

RUN apt install -y python3 python3-dev


RUN apt install -y sshpass \
		tar \
		freetds-dev

RUN apt install -y g++ \
		unixodbc \
		unixodbc-dev \
		gcc \
		make		

RUN apt install -y python3-pip

ENV PIP_DEFAULT_TIMEOUT=300

RUN pip install --upgrade pip



RUN pip3 install \
		ansible==3.2.0 \
		botocore==1.21.38 \
		boto==2.49.0 \
		PyYAML==5.4.1 \
		boto3==1.18.38 \
		pyvmomi==7.0.3 \
		kubernetes==21.7.0 \
		jsonpatch==1.32 \
		pymssql==2.2.5 \
		pyodbc

RUN pip install ansible-core ansible pywinrm


RUN ansible-galaxy collection install azure.azcollection:==1.12.0


RUN ansible-galaxy collection install ansible.windows


RUN pip install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements-azure.txt
# Add K8s anisble module and pre-req
RUN pip install kubernetes==23.3.0

RUN ansible-galaxy collection install kubernetes.core

RUN ansible-galaxy collection install community.general
# Install Azure cli
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ impish main" > /etc/apt/sources.list.d/azure-cli.list
RUN apt update
RUN apt install -y azure-cli
# Add helm

RUN wget https://get.helm.sh/helm-v3.7.2-linux-amd64.tar.gz -O - | tar -xz
RUN mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-amd64 $$ \
      && \
    chmod +x /usr/bin/helm
# Clean up
RUN apt remove linux-libc-dev --yes
RUN apt-get autoremove --yes
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*




# Install Kubelogin and Kubectl

ARG KUBELOGIN_VERSION="v0.0.13"
ARG KUBELOGIN_SHA256="b27e0ffcf110515f739c1b88aab65ef239727479a890babb00773bb44fa7cd10"




RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin

RUN wget -O /kubelogin.zip https://github.com/Azure/kubelogin/releases/download/${KUBELOGIN_VERSION}/kubelogin-linux-amd64.zip

RUN echo "$KUBELOGIN_SHA256  /kubelogin.zip" | sha256sum -c -
RUN unzip /kubelogin.zip && \
    	rm /kubelogin.zip && \
		mv bin/linux_amd64/kubelogin /usr/bin/kubelogin

# Install MS ODDBC
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN apt-get update
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql18
RUN ACCEPT_EULA=Y apt-get install -y mssql-tools18



RUN rm -rf /root/.cache

VOLUME ["/tmp/playbook"]

WORKDIR /tmp/playbook

ENTRYPOINT ["ansible-playbook"]

CMD ["--version"]
