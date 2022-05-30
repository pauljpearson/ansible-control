FROM python:3.7-alpine
ENV PYMSSQL_BUILD_WITH_BUNDLED_FREETDS=1
RUN apk add --update --no-cache \
        wget \
		git
RUN wget https://get.helm.sh/helm-v3.7.2-linux-amd64.tar.gz -O - | tar -xz
RUN mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-amd64 $$ \
      && \
    chmod +x /usr/bin/helm
RUN apk add --no-cache \
		bzip2 \
		curl \
		file \
		gzip \
		gnupg \
		libffi \
		libffi-dev \
		krb5 \
		krb5-dev \
		krb5-libs \
		musl-dev \
		openssh \
		openssl-dev \
		# python3 \
		# python3-dev=3.9.7-r4 \
		# py3-cffi \
		# py3-cryptography=3.3.2-r3 \
		# py3-setuptools=52.0.0-r4 \
		sshpass \
		tar \
		bind-tools \
		freetds-dev \
		g++ \
		unixodbc \
		unixodbc-dev
RUN apk add --no-cache --virtual build-dependencies \
		gcc \
		make
		# && \
RUN python3 -m ensurepip --upgrade
	#   && \
RUN pip3 install \
		ansible[azure]==3.2.0 \
		botocore==1.21.38 \
		boto==2.49.0 \
		PyYAML==5.4.1 \
		boto3==1.18.38 \
		pyvmomi==7.0.3 \
		pywinrm[kerberos]==0.4.1 \
		kubernetes==21.7.0 \
		jsonpatch==1.32 \
		pymssql==2.2.5 \
		pyodbc
	# 	&& \
RUN ansible-galaxy collection install \
	    azure.azcollection \
	    kubernetes.core \
	    ansible.windows \
		community.general
	# 	&& \
RUN pip3 install \
	    -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements-azure.txt
	# 	&& \

RUN curl -O https://download.microsoft.com/download/b/9/f/b9f3cce4-3925-46d4-9f46-da08869c6486/msodbcsql18_18.0.1.1-1_amd64.apk 
	# 	&& \
RUN curl -O https://download.microsoft.com/download/b/9/f/b9f3cce4-3925-46d4-9f46-da08869c6486/mssql-tools18_18.0.1.1-1_amd64.apk 
	# 	&& \
RUN curl -O https://download.microsoft.com/download/b/9/f/b9f3cce4-3925-46d4-9f46-da08869c6486/msodbcsql18_18.0.1.1-1_amd64.sig 
	# 	&& \
RUN curl -O https://download.microsoft.com/download/b/9/f/b9f3cce4-3925-46d4-9f46-da08869c6486/mssql-tools18_18.0.1.1-1_amd64.sig 
	# 	&& \
RUN curl https://packages.microsoft.com/keys/microsoft.asc  | gpg --import - 
	# 	&& \
RUN gpg --verify msodbcsql18_18.0.1.1-1_amd64.sig msodbcsql18_18.0.1.1-1_amd64.apk 
	# 	&& \
RUN gpg --verify mssql-tools18_18.0.1.1-1_amd64.sig mssql-tools18_18.0.1.1-1_amd64.apk 
	# 	&& \
RUN apk add --allow-untrusted \
		msodbcsql18_18.0.1.1-1_amd64.apk \
		mssql-tools18_18.0.1.1-1_amd64.apk 
RUN pip install azure-cli
	# 	&& \
RUN apk del build-dependencies 
	# 	&& \
RUN rm -rf /root/.cache

VOLUME ["/tmp/playbook"]

WORKDIR /tmp/playbook

ENTRYPOINT ["ansible-playbook"]

CMD ["--version"]
