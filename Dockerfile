# syntax=docker/dockerfile:1.3-labs

FROM ubuntu:18.04

RUN export DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install vim git net-tools emacs python3 python3-pip wget curl sudo openssh-server

RUN pip3 install --upgrade pip

RUN cd /home
RUN git clone https://github.com/electricalcoder/Cornus
RUN cd Cornus

RUN echo root > info.txt
RUN echo /home/Cornus/ >> info.txt

RUN python3 install.py install_local 0
RUN python3 install.py config_local 0

RUN mkdir /run/ssh

CMD ["/usr/sbin/sshd", "-D"]

EXPOSE 22
