FROM ubuntu:22.04

# Installation des packages
RUN apt-get update -qq && \
    apt-get install software-properties-common build-essential curl libc6-i386 libc6-x32 \
    libxi6 libxrender1 libxtst6 libasound2 libfreetype6 \
    libssl-dev libffi-dev zlib1g-dev libbz2-dev libsqlite3-dev -y > /dev/null && \
    rm -rf /var/lib/apt/lists/*

# Installation de Java
RUN curl -s -O https://download.oracle.com/java/20/archive/jdk-20_linux-x64_bin.deb
RUN dpkg -i ./jdk-20_linux-x64_bin.deb
RUN rm jdk-20_linux-x64_bin.deb

# Définition des chemins Java disponible globalement
ENV JAVA_HOME="/usr/lib/jvm/jdk-20"
ENV PATH="$PATH:/usr/lib/jvm/jdk-20/bin"

# Les instructions spécifiques à mon application
COPY HelloWorld.java HelloWorld.java
RUN javac HelloWorld.java

ENTRYPOINT ["java", "-cp", ".", "HelloWorld"]