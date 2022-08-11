FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y
RUN apt-get install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev git  -y

WORKDIR /opt
RUN git clone https://github.com/riscv-collab/riscv-gnu-toolchain.git -b 2022.06.10

WORKDIR /opt/riscv-gnu-toolchain
RUN git submodule init && git submodule update 

WORKDIR /opt/riscv-gnu-toolchain/riscv-gcc
RUN git checkout riscv-gcc-12.1.0 && git checkout 4f015efba2a89acc6e078d3abf86e69d52932ddf 

WORKDIR /opt/riscv-gnu-toolchain
RUN ./configure --prefix=/opt/gcc-11.1.0-nolibc/riscv64-linux  --enable-multilib
RUN sed -i "s/linux-gnu/linux/g" Makefile
RUN sed -i "s/unknown-//g" Makefile
RUN sed -i "s/,c++//g" Makefile
RUN sed -i "s/,fortran//g" Makefile
RUN make linux -j`nproc`

WORKDIR /opt/gcc-11.1.0-nolibc/riscv64-linux
RUN rm -rf sysroot include/* bin/*gdb* riscv64-linux/lib32 riscv64-linux/lib64 riscv64-linux/include
RUN find ./bin -exec strip {} \; 
RUN find ./libexec -exec strip {} \; 

WORKDIR /opt
RUN tar Jcvf x86_64-gcc-12.1.0-nolibc-riscv64-linux.tar.xz gcc-11.1.0-nolibc

WORKDIR /opt/build
RUN cp /opt/x86_64-gcc-12.1.0-nolibc-riscv64-linux.tar.xz .

VOLUME /opt/build
