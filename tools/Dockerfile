# /********************************************************************************
# * Copyright (c) 2022 Contributors to the Eclipse Foundation
# *
# * See the NOTICE file(s) distributed with this work for additional
# * information regarding copyright ownership.
# *
# * This program and the accompanying materials are made available under the
# * terms of the Apache License 2.0 which is available at
# * http://www.apache.org/licenses/LICENSE-2.0
# *
# * SPDX-License-Identifier: Apache-2.0
# ********************************************************************************/

# Download base image of Ubuntu LTS
FROM ubuntu:20.04

# If you get proxy errors, make sure Docker is configured correctly.
# Hint: https://dev.to/zyfa/setup-the-proxy-for-dockerfile-building--4jc8

# User permission issues explained
# https://jtreminio.com/blog/running-docker-containers-as-current-host-user/

#TODO: fix and uncomment:  This is needed for local development under linux
# ARG USERNAME=dockeruser
# ARG USER_ID=1000
# ARG GROUP_ID=$USER_ID

# To prevent interactive shells
ENV DEBIAN_FRONTEND=noninteractive

# Install apt & root utils needed inside devcontainer
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && apt-get upgrade -y


RUN apt-get -qqy install --no-install-recommends \
    apt-utils software-properties-common binutils-common sudo

# devcontainer installs moved here
RUN apt-get -qqy install --no-install-recommends \
  curl wget zip \
  xz-utils \
  apt-transport-https \
  file \
  locales locales-all

# Install dev utilities
RUN apt-get -qqy install --no-install-recommends \
  git \
  can-utils

# NOTE: spit to reduce layer size (ttl.sh upload)
RUN apt-get -qqy install --no-install-recommends \
  doxygen

# Install build tools
RUN apt-get -qqy install --no-install-recommends \
  cmake make ccache

## compilers
#   compiler version must be sync with conan build profile
RUN apt-get -qqy install --no-install-recommends \
  g++
# NOTE: g++aarch64 is spit to reduce layer size (ttl.sh upload)
RUN apt-get -qqy install --no-install-recommends \
  g++-aarch64-linux-gnu

RUN apt-get -qqy install --no-install-recommends \
  lcov \
	gcovr \
	clang-format \
	cppcheck \
	valgrind \
  jq

# Install PIP
RUN apt-get -qqy install --fix-missing \
  python3 \
  python3-pip

# Default pip and setuptools are too old...
RUN pip3 install --upgrade pip setuptools

# conan: dependency management
# conan needed > 1.43 for gtest and < 2.0
# cantools: code generation from .dbc file
RUN pip3 install \
	'conan==1.56.0' \
	'cantools==37.0.1'

# Install Rust tools and prerequists needed for the databroker
# RUN apt-get -y install --no-install-recommends curl jq
# RUN curl https://sh.rustup.rs -sSf | sh -s -- --profile default --default-toolchain 1.60 -y

# Install python tools and prerequists needed for all python using subfolders
COPY hvac_service/requirements-dev.txt hvac_service/requirements-dev.txt
COPY integration_test/requirements-dev.txt integration_test/requirements-dev.txt
RUN pip3 install -U -r hvac_service/requirements-dev.txt
RUN pip3 install -U -r integration_test/requirements-dev.txt

# python3.9 is required for feedercan vscode task
RUN apt-get install -qqy python3.9
# hack to install proper version of pip3.9
RUN curl https://bootstrap.pypa.io/get-pip.py | python3.9
RUN pip3.9 install --upgrade pip setuptools

# cleanup cahces to minimize image size
RUN pip3 cache purge
RUN apt-get clean

WORKDIR /workspace
