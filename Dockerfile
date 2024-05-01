# syntax=docker/dockerfile:1.2

# ETAP 1 Budowa aplikacji Node.js
FROM scratch AS etap1
ADD alpine-minirootfs-3.19.1-x86_64.tar /

# Zadeklarowany klucz, ale nie wartość
ARG BASE_VERSION

# Deklaracja zmiennej Environment
# Jeżeli BASE_VERSION nie będzie posiadało wartości
# To wersja ta będzie wpisana defaultowo jako v1
ENV APP_VERSION=${BASE_VERSION:-v1}

# Instalacja pakietów niezbędnych do realizacji testu 
# Instalacja pakietu openssh-client i git za pomocą menedżera 
# pakietów apk
RUN apk add --update nodejs npm && rm -rf /var/cache/apk/* \
    && apk add --no-cache openssh-client git \
    && mkdir -p -m 0700 ~/.ssh \
    && ssh-keyscan github.com >> ~/.ssh/known_hosts \
    && eval $(ssh-agent)
# apk add --no-cache openssh-client git instaluje clienta Git
# ssh-keyscan github.com >> ~/.ssh/known_hosts: 
# Skanuje klucz hosta dla serwera GitHub i dodaje go do pliku 
# ~/.ssh/known_hosts.
# eval $(ssh-agent): Uruchamia agenta SSH

# Deklaracja katalogu roboczego
WORKDIR /usr/app

# klonowanie repozytorium z GitHub do środowiska Dockera, 
# przy użyciu klucza SSH zdefiniowanego wcześniej.
# flaga --mount=type=ssh umożliwia zamontowanie klucza 
# prywatnego SSH w kontenerze Docker.
RUN --mount=type=ssh git clone git@github.com:MarekP21/pawcho6.git pawcho6

# Kopiowanie niezbędnych zależności 
COPY ./package.json ./
# Instalacja tych zależności 
RUN npm install

# Kopiowanie kodu aplikacji wewnątrz obrazu
COPY ./index.js ./

#-----------------------------------------------------------------------
# ETAP 2 Konfiguracja i uruchomienie nginx
FROM nginx:alpine3.19 AS etap2

# Ponowne zadeklarowanie zmiennych
ARG BASE_VERSION
ENV APP_VERSION=${BASE_VERSION:-v1}

# Instalacja curl 
RUN apk add --update curl && \
    apk add --update nodejs npm && \
    rm -rf /var/cache/apk/*

# Skopiowanie z etapu 1 do katalogu domyślnego serwera HTTP
COPY --from=etap1 /usr/app /usr/share/nginx/html/

# Skopiowanie pliku konfiguracyjnego 
# nginx.conf do katalogu /etc/nginx/conf.d/
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Deklaracja katalogu roboczego
WORKDIR /usr/share/nginx/html

# Informacja o porcie wewnętrznym kontenera, 
# na ktorym "nasłuchuje" aplikacja
EXPOSE 8080

# Informacja czy aplikacja działa
# procedura weryfikacji działania uruchomionej aplikacji
HEALTHCHECK --interval=10s --timeout=1s \
    CMD curl -f http://localhost:8080/ || exit 1

# Domyśle polecenie przy starcie kontenera 
CMD ["npm", "start", "-g", "deamon off"]