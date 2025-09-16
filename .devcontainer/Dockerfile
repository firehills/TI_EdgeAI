# See https://mcr.microsoft.com/en-us/artifact/mar/devcontainers/python/about
# FROM mcr.microsoft.com/devcontainers/python:1-3.12-bullseye
# FROM mcr.microsoft.com/devcontainers/python:3.12-bookworm
FROM ubuntu:22.04
#MAINTAINER Phil Hill <hill.philip@gmail.com>
ARG USERNAME=vscode

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y upgrade
RUN apt-get auto-remove -y

RUN apt-get install -y --no-install-recommends git ca-certificates build-essential pkg-config \
libreadline-dev gcc-arm-none-eabi libnewlib-dev qtbase5-dev \
libbz2-dev liblz4-dev libbluetooth-dev libpython3-dev libssl-dev libgd-dev 

ENV SHELL=/bin/bash