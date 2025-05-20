# Install the base requirements for the app.
# This stage is to support development.
FROM ubuntu:latest
WORKDIR /Brainstorm

COPY MATLAB_Runtime_R2021a_Update_8_glnxa64.zip .

VOLUME ["/input", "/output"]

RUN apt update -y
RUN apt upgrade -y
RUN apt install -y build-essential unzip nano git openjdk-8-jre

# RUN git clone https://github.com/CorentinLabelle/Brainstorm-Tool.git
RUN mkdir -p /Brainstorm/Brainstorm-Tool/src
COPY src/ /Brainstorm/Brainstorm-Tool/src

RUN mkdir /Brainstorm/Brainstorm-Tool/bin
COPY bin /Brainstorm/Brainstorm-Tool/bin

RUN unzip MATLAB*
RUN echo "agreeToLicense=yes" > input.txt
RUN ./install -mode silent -inputfile input.txt
RUN echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/MATLAB/MATLAB_Runtime/v910/runtime/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v910/bin/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v910/sys/os/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v910/extern/bin/glnxa64" > set_library_path.txt
