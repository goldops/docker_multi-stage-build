# Étape 1 : Compilation
FROM ubuntu:22.04 AS build

RUN apt-get update -qq && \
    apt-get install build-essential curl -y > /dev/null

RUN curl -s -O https://download.oracle.com/java/20/archive/jdk-20_linux-x64_bin.deb && \
    dpkg -i ./jdk-20_linux-x64_bin.deb && \
    rm jdk-20_linux-x64_bin.deb

ENV JAVA_HOME="/usr/lib/jvm/jdk-20"
ENV PATH="$PATH:/usr/lib/jvm/jdk-20/bin"

COPY HelloWorld.java HelloWorld.java
RUN javac HelloWorld.java

# Étape 2 : Image finale minimaliste
FROM eclipse-temurin:20-jre

# Copie du résultat de la compilation
COPY --from=build HelloWorld.class .

ENTRYPOINT ["java", "-cp", ".", "HelloWorld"]