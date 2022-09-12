FROM centos:7.7.1908 AS builder

RUN yum -y install wget make jss gmp-devel mpfr-devel libmpc-devel zip unzip gcc gcc-c++ java-1.8.0-openjdk-devel \
&& mkdir -p /root/{src/objdir,gcc65}

WORKDIR /root/src
RUN wget http://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-6.5.0/gcc-6.5.0.tar.gz \
&& wget ftp://sourceware.org/pub/java/ecj-4.9.jar \
&& cp ecj-4.9.jar /usr/share/java/ecj.jar \
&& gunzip *.gz && tar xfv *.tar

WORKDIR /root/src/objdir
RUN ../gcc-6.5.0/configure --enable-threads=posix --prefix=/root/gcc65 --enable-shared --disable-multilib --enable-languages=c,c++,java --enable-libgcj-multifile --with-ecj-jar=/usr/share/java/ecj.jar \
&& make bootstrap && make && make install \
&& cp /root/gcc65/lib64/libgcj_bc.so.1 /lib64/ && cp /root/gcc65/lib64/libgcj.so.17 /lib64/


FROM centos:7.7.1908

WORKDIR /root
RUN mkdir gcc65 \
&& yum -y install java-1.8.0-openjdk-devel wget jss libmpc-devel glibc-devel \
&& wget ftp://sourceware.org/pub/java/ecj-4.9.jar \
&& mv ecj-4.9.jar /usr/share/java/ecj.jar

COPY --from=builder /root/gcc65 /root/gcc65
RUN cp /root/gcc65/lib64/libgcj_bc.so.1 /lib64/ && cp /root/gcc65/lib64/libgcj.so.17 /lib64/
ENV PATH="/root/gcc65/bin:${PATH}"

LABEL maintainer="chrisjshore@icloud.com" \
      description="This is a custom build of GCC 6.5 with Java enabled for the purpose of testing GCJ in a RHEL/CentOS 7 environment" \
      errata="OpenJDK 8 is included for completeness of Java development"