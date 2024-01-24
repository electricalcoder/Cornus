# syntax=docker/dockerfile:1.3-labs

FROM ubuntu:18.04

ARG NODE_ID

RUN export http_proxy="http://172.17.0.1:7890"
RUN export https_proxy="http://172.17.0.1:7890"

RUN cat > /etc/apt/sources.list <<EOF
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse

deb http://security.ubuntu.com/ubuntu/ bionic-security main restricted universe multiverse
# deb-src http://security.ubuntu.com/ubuntu/ bionic-security main restricted universe multiverse
EOF
RUN apt update

RUN apt install vim git net-tools emacs python3 python3-pip wget curl sudo

RUN pip3 install --upgrade pip
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

RUN cd /home
RUN git clone https://github.com/electricalcoder/Cornus
RUN cd Cornus

RUN echo root > info.txt
RUN echo /home/Cornus/ >> info.txt

RUN export DEBIAN_FRONTEND=noninteractive
echo "check_certificate = off" >> ~/.wgetrc
RUN python3 install.py install_local ${NODE_ID}
