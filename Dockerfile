FROM centos:7
MAINTAINER "Eric Rumble"

# Setup working directory
ENV home /workspace
RUN mkdir ${home}
WORKDIR ${home}

# Ensure the container is up to date
RUN yum makecache fast \
 && yum update -y \
 && yum install -y \
        createrepo \
        python \
 && yum clean all

# Install the AWS CLI
ADD https://bootstrap.pypa.io/get-pip.py .
RUN chmod 644 ./get-pip.py \
 && python get-pip.py \
 && pip install awscli

# drop the rpm-build script and spec file
COPY update_repo.sh .
RUN chmod 755 ./update_repo.sh && ln -s ${home}/update_repo.sh /usr/local/bin/update_repo

# set the entry point to update_repo.sh so we can just docker run <container>
ENTRYPOINT ["update_repo"]
