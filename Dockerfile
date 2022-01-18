FROM alpine:3.13.6

RUN apk add --update --no-cache \
        wget \
		git && \
    wget https://get.helm.sh/helm-v3.7.2-linux-amd64.tar.gz -O - | tar -xz && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-amd64 $$ \
      && \
    chmod +x /usr/bin/helm && \
    apk add --no-cache \
		bzip2 \
		file \
		gzip \
		libffi \
		libffi-dev \
		krb5 \
		krb5-dev \
		krb5-libs \
		musl-dev \
		openssh \
		openssl-dev \
		python3-dev=3.8.10-r0 \
		py3-cffi \
		py3-cryptography=3.3.2-r0 \
		py3-setuptools=51.3.3-r0 \
		sshpass \
		tar \
		&& \
	apk add --no-cache --virtual build-dependencies \
		gcc \
		make \
		&& \
	python3 -m ensurepip --upgrade \
	  && \
	pip3 install \
		ansible==3.2.0 \
		botocore==1.21.38 \
		boto==2.49.0 \
		PyYAML==5.4.1 \
		boto3==1.18.38 \
		awscli==1.20.38 \
		pyvmomi==7.0.3 \
		pywinrm[kerberos]==0.4.1 \
		kubernetes==21.7.0 \
		jsonpatch==1.32 \
		&& \
    ansible-galaxy collection install \
	    azure.azcollection \
	    kubernetes.core \
		&& \
	pip3 install \
	    -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements-azure.txt \
		&& \
	apk del build-dependencies \
		&& \
	rm -rf /root/.cache

VOLUME ["/tmp/playbook"]

WORKDIR /tmp/playbook

ENTRYPOINT ["ansible-playbook"]

CMD ["--version"]