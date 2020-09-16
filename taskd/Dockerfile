FROM ubuntu:latest

MAINTAINER fmount <fmount9@autistici.org>

ENV TASKDDATA /var/taskd
ENV DOMAIN localhost
ENV PORT 53589
ENV uid 1002
ENV gid 1002
ENV group taskd
ENV user taskd
ENV DEBIAN_FRONTEND noninteractive
ENV HOSTNAME taskandtomatos

RUN groupadd -g $gid $group && \
	useradd -m -u $uid -g $gid $user && \
	export TASKDDATA=$TASKDDATA && \
	mkdir -p $TASKDDATA

RUN apt-get update && \
	apt-get install -y build-essential \
	git \
	curl \
	wget \
	ca-certificates \
	cmake \
	gnutls-bin \
	libgnutls28-dev \
	uuid-dev \
	uuid-runtime \
	sudo \
	task

RUN uuidgen | sed 's/\-//g' > /etc/machine-id

RUN git clone https://git.tasktools.org/TM/taskd.git /opt/taskd && \
	cd /opt/taskd; \
	git checkout -b origin/1.2.0; \
	cmake .; \
	make; \
	make install;

# Clean the apt cache
RUN rm -rf /var/lib/apt/lists/*

# Make the first configuration
# TODO: Change taskandtomatos with the variable ...
RUN taskd init; \
	taskd config --force server $DOMAIN:$PORT; \
	cd /opt/taskd/pki; \
	sed -i 's/localhost/taskandtomatos/g' vars; \
	./generate; \
	mv *.pem $TASKDDATA; \
	chown -R $user. $TASKDDATA; \
	chmod 0644 $TASKDDATA/config; \
	# Config all generated files
	taskd config --force client.cert $TASKDDATA/client.cert.pem; \
	taskd config --force client.key $TASKDDATA/client.key.pem; \
	taskd config --force server.cert $TASKDDATA/server.cert.pem; \
	taskd config --force server.key $TASKDDATA/server.key.pem; \
	taskd config --force server.crl $TASKDDATA/server.crl.pem; \
	taskd config --force ca.cert $TASKDDATA/ca.cert.pem

VOLUME /var/taskd
EXPOSE 53589

COPY run.sh /tmp/run.sh
RUN  chmod +x /tmp/run.sh

USER $user
RUN export TASKDDATA=$TASKDDATA
ENTRYPOINT ["/tmp/run.sh"]
