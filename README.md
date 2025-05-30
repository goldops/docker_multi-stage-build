Voici un `README.md` qui met en avant l’intérêt du multi-stage build dans Docker, en s’appuyant sur ton exemple. Il montre de façon claire et directe la différence entre une image monolithique et une image optimisée via multi-stage build.

---

# Optimisation des images Docker avec le **Multi-Stage Build**

## 💡 Objectif

Réduire la taille de l’image Docker finale en séparant la phase de **build** de celle de **l'exécution**.

## 🚨 Problème

L'image suivante compile un simple programme Java (`HelloWorld.java`) dans un conteneur basé sur Ubuntu :

```dockerfile
FROM ubuntu:22.04

# Installation des dépendances système et outils de compilation
RUN apt-get update -qq && \
    apt-get install software-properties-common build-essential curl libc6-i386 libc6-x32 \
    libxi6 libxrender1 libxtst6 libasound2 libfreetype6 \
    libssl-dev libffi-dev zlib1g-dev libbz2-dev libsqlite3-dev -y > /dev/null && \
    rm -rf /var/lib/apt/lists/*

# Installation de Java
RUN curl -s -O https://download.oracle.com/java/20/archive/jdk-20_linux-x64_bin.deb
RUN dpkg -i ./jdk-20_linux-x64_bin.deb
RUN rm jdk-20_linux-x64_bin.deb

# Définition des chemins Java
ENV JAVA_HOME="/usr/lib/jvm/jdk-20"
ENV PATH="$PATH:/usr/lib/jvm/jdk-20/bin"

# Compilation
COPY HelloWorld.java HelloWorld.java
RUN javac HelloWorld.java

# Exécution
ENTRYPOINT ["java", "-cp", ".", "HelloWorld"]
```

🔍 **Taille estimée de l’image : > 500 Mo**
Elle embarque **tout l’environnement de compilation**, inutile à l’exécution.

---

## ✅ Solution : **Multi-Stage Build**

On peut séparer la phase de build (compilation) et la phase d'exécution (runtime) pour ne conserver que l'essentiel.

### Exemple avec Multi-Stage Build :

```dockerfile
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
```

---

## 🎯 Résultat
```
| Image            | Taille approximative | Contenu                                        |
| ---------------- | -------------------- | ---------------------------------------------- |
| Sans multi-stage | \~500 Mo             | Build tools, JDK, dépendances système, runtime |
| Avec multi-stage | \~200 Mo             | Seulement le JRE + bytecode compilé            |

```
---

## 🧠 Conclusion

Le **multi-stage build** permet de :

* Ne pas embarquer les outils de compilation ou les dépendances inutiles.
* Réduire drastiquement la **taille des images**.
* Limiter la **surface d’attaque** (moins de packages → moins de vulnérabilités).
* Optimiser le **temps de transfert** des images (pull/push).

C’est une **bonne pratique incontournable** en production.
