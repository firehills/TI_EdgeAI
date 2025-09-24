# See https://mcr.microsoft.com/en-us/artifact/mar/devcontainers/python/about
# FROM mcr.microsoft.com/devcontainers/python:1-3.12-bullseye
# FROM mcr.microsoft.com/devcontainers/python:3.12-bookworm
FROM ubuntu:22.04
#MAINTAINER Phil Hill <hill.philip@gmail.com>
ARG USERNAME=vscode

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y upgrade
RUN apt-get auto-remove -y

RUN apt-get install -y --no-install-recommends git ca-certificates build-essential nano htop pkg-config curl sudo locales make  libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev  libncursesw5-dev \
xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev python3 python3-pip python3-setuptools

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN useradd -ms /bin/bash vscode && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER vscode 


ENV SOC=am62a
ENV SHELL=/bin/bash
#RUN sudo chown -R vscode /opt/ti 
