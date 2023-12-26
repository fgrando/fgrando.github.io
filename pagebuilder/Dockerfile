# Download base image ubuntu 22.04
FROM ubuntu:22.04

# LABEL about the custom image
LABEL maintainer="fgrando@github"
LABEL version="0.1"
LABEL description="This is a custom docker image to build create the github pages data"

RUN apt update
RUN apt install wget make git -y
RUN apt clean

ENV mdbook_release https://github.com/rust-lang/mdBook/releases/download/v0.4.36/mdbook-v0.4.36-x86_64-unknown-linux-gnu.tar.gz

RUN cd ~ && wget ${mdbook_release} && tar -zxvf mdbook* && mv mdbook /usr/bin/

VOLUME ["/var/sources"]



# create and run the image as follows:
# docker build -t pagebuilder .
# docker run -ti -v ~/fgrando.github.io/:/var/sources --rm pagebuilder /bin/bash
# docker run -v ~/fgrando.github.io/:/var/sources --rm pagebuilder /bin/bash -c 'cd /var/sources && make'
