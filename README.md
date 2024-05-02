# Programowanie Aplikacji w Chmurze Obliczeniowej

      Marek Prokopiuk
      grupa dziekańska: 6.7
      numer albumu: 097710
## Laboratorium 6<br>Konfiguracja i wykorzystanie klienta CLI dla usług Github.
<p align="justify">Przedstawione zostało rozwiązanie zadania nieobowiązkowego do laboratorium 6. Należało wykorzystać w nim opracowany na potrzeby wcześniejszych zajęć plik Dockerfile dla aplikacji webowej uruchamianej w oparciu o serwer Nginx oraz budowanej w oparciu o metodę wieloetapową. Wykorzystane zostało więc repozytorium z rozwiązaniem zadania z <a href="https://github.com/MarekP21/Docker_Lab5">Laboratorium 5</a>. </p>

---

### Stworzenie repozytorium z wykorzystaniem CLI
<p align="justify">Na początku należało zalogować się do konta Github za pomocą gh CLI. Github CLI oferuje dwie podstawowe metody logowania, a mianowicie autoryzację w trybie interaktywnym oraz autoryzację w oparciu o osobisty token dostępowy. Zostało wykorzystane logowanie przy użyciu wcześniej wygenerowanego tokena PAT. Proces logowania widać na poniższym rysunku.</p><br>
<p align="center">
  <img src="https://raw.githubusercontent.com/MarekP21/pawcho6/main/screeny/1. Logowanie przy pomocy CLI z tokenem.png" style="width: 80%; height: 80%" /></p>
<p align="center">
  <i>Rys. 1. Logowanie przy pomocy CLI z tokenem</i>
</p>

<p align="justify">Następnie przy pomocy narzędzia gh trzeba było utworzyć publiczne repozytorium na Github o nazwie <em>pawcho6</em>. Użyte zostało polecenie gh w trybie interaktywnym, gdyż wszystkie niezbędne parametry podawane były w formie odpowiedzi na kolejne pytania. Poniżej widać efekt polecenia.</p><br>
<p align="center">
  <img src="https://raw.githubusercontent.com/MarekP21/pawcho6/main/screeny/2. Stworzenie nowego repozytorium.png" style="width: 80%; height: 80%" /></p>
<p align="center">
  <i>Rys. 2. Stworzenie nowego repozytorium</i>
</p>

<p align="justify">Ostatnim elementem tego etapu było powiązanie nowo powstałego repozytorium ze zrealizowanym zadaniem z laboratorium 5. W tym celu sklonowane zostało do <em>pawcho6</em> repozytorium z wykonanym wcześniej plikiem Dockerfile, aby móc go potem odpowiednio zmodyfikować. Widać to na poniższym zrzucie ekranu.</p><br>
<p align="center">
  <img src="https://raw.githubusercontent.com/MarekP21/pawcho6/main/screeny/3. Sklonowanie repozytorium z rozwiązaniem Zadania 5.png" style="width: 80%; height: 80%" /></p>
<p align="center">
  <i>Rys. 3. Sklonowanie repozytorium z rozwiązaniem Zadania 5</i>
</p>

---

### Zmodyfikowanie pliku Dockerfile
<p align="justify">W dalszej części zadania należało zmodyfikować istniejący plik Dockerfile z rozwiązania z zadania 5 tak, aby pełnił on rolę frontendu dla silnika Buildkit oraz pozwalał pobrać zawartość przygotowanego repozytorium i na jego podstawie zbudować obraz Docker. W pliku Dockerfile należało również zdefiniować pobieranie repozytorium z wykorzystaniem protokołu SSH. Dodane zostały w tym celu odpowiednie polecenia znalezione pod <a href="https://medium.com/@tonistiigi/build-secrets-and-ssh-forwarding-in-docker-18-09-ae8161d066">tym linkiem</a>.</p>
<p align="justify">Na samym początku została dodana dyrektywa</p>

      # syntax=docker/dockerfile:1.2

<p align="justify">Jest ona używana w celu określenia, którą wersję składni Dockerfile należy użyć podczas budowania obrazu. Właśnie w składni Dockerfile 1.2 można korzystać z takich funkcji jak RUN --mount, --secret, czy --ssh, które pozwalają na bezpieczne i efektywne zarządzanie tajnymi danymi podczas budowy obrazów Docker.<br>Kolejnymi dodanymi poleceniami są:</p>

      RUN apk add --update nodejs npm && rm -rf /var/cache/apk/* \
          && apk add --no-cache openssh-client git \
          && mkdir -p -m 0700 ~/.ssh \
          && ssh-keyscan github.com >> ~/.ssh/known_hosts \
          && eval $(ssh-agent)

<p align="justify">Z nowo dodanych poleceń następuje tu instalacja pakietu openssh-client i git za pomocą menedżera pakietów apk. Klucz hosta jest skanowany dla serwera Github, a następnie dodawany do pliku ~/.ssh/known_hosts. Kolejne polecenie uruchamia agenta SSH.<br>Ostatnią dokonaną zmianą w kodzie jest wprowadzenie następującego polecenia:</p>

      RUN --mount=type=ssh git clone git@github.com:MarekP21/pawcho6.git pawcho6

<p align="justify">Powoduje ono klonowanie repozytorium z Github do środowiska Dockera, przy użyciu klucza SSH zdefiniowanego wcześniej. Flaga --mount=type=ssh umożliwia zamontowanie klucza  prywatnego SSH w kontenerze Docker.<br>
<p align="justify">Oprócz pliku Dockerfile w celu realizacji zadania potrzebne są podobnie jak w przypadku laboratorium 5 następujące pliki:</p>

  - <a href="https://github.com/MarekP21/pawcho6/blob/main/index.js">index.js</a>
  - <a href="https://github.com/MarekP21/pawcho6/blob/main/nginx.conf">nginx.conf</a>
  - <a href="https://github.com/MarekP21/pawcho6/blob/main/package.json">package.json</a>
  - <a href="https://github.com/MarekP21/pawcho6/blob/main/alpine-minirootfs-3.19.1-x86_64.tar">alpine-minirootfs-3.19.1-x86_64</a>
  
<p>Poniżej została umieszczona cała zawartość pliku <a href="https://github.com/MarekP21/pawcho6/blob/main/Dockerfile">Dockerfile</a>.</p><br>

```diff
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
```

---

### Skonfigurowanie klienta builtctl
<p align="justify">W celu wykonania dalszej części zadania, potrzebne było zainstalowanie klienta buildctl na hoście przeznaczonym do zarządzania procesem budowy obrazu. Pobrana została odpowiednia wersja Buildkit z Github, aby działała na WSL2 Ubuntu-20.04. Następnie pobrane pliki zostały wyodrębione i przeniesione do katalogu /bin. Aby można było wykorzystywać potrzebne polecenia należało jeszcze dodać uprawnienia wykonywania odpowiednim plikom. Po tym wszystkim można było sprawdzić poprawność konfiguracji klienta buildctl.</p><br>
<p align="center">
  <img src="https://raw.githubusercontent.com/MarekP21/pawcho6/main/screeny/4. Sprawdzenie poprawności konfiguracji klienta buildctl po jego zainstalowaniu.png" style="width: 80%; height: 80%" /></p>
<p align="center">
  <i>Rys. 4. Sprawdzenie poprawności konfiguracji klienta buildctl</i>
</p>

<p align="justify">Nastęnie należało dokonać instalacji deamon-a Buildkit w oparciu o oficjalny obraz Docker <em>moby/buildkit</em>. Wykorzystane zostało w tym celu polecenie z materiałów wykładowych (Wykład 5 - strona 12). Efekt wykonania tego polecenia widać na poniższym rysunku.</p><br>
<p align="center">
  <img src="https://raw.githubusercontent.com/MarekP21/pawcho6/main/screeny/5. Instalacja dedykowanego kontenera i zdefiniowanie domyślnego hosta.png" style="width: 80%; height: 80%" /></p>
<p align="center">
  <i>Rys. 5. Instalacja dedykowanego kontenera i zdefiniowanie domyślnego hosta</i>
</p>

---

### Zbudowanie obrazu
<p align="justify">Kluczowym momentem zadania było zbudowanie obrazu na podstawie utworzonego pliku Dockerfile w oparciu o deamon-a Buildkit uruchomionego w dedykowanym kontenerze. Wykorzystane zostało w tym celu polecenie podobne do tego z przykładu wykładowego (Wykład 5 - strona 15).</p>

    buildctl build \
        --frontend=dockerfile.v0 \
        --ssh default=$SSH_AUTH_SOCK \
        --local context=. \
        --local dockerfile=. \
        --opt build-arg:BASE_VERSION=v2 \
        --output type=image,name=ghcr.io/marekp21/pawcho6:lab6,push=true

<p align="justify">Szczegóły Polecenia</p>

  * --frontend=dockerfile.v0: Określa format pliku Dockerfile używany podczas procesu budowania.
  * --ssh default=$SSH_AUTH_SOCK: Konfiguruje uwierzytelnianie SSH dla pobierania repozytoriów podczas budowania.
  *  --local context=.: Ustawia lokalizację kontekstu budowy na bieżący katalog.
  * --local dockerfile=.: Określa lokalizację pliku Dockerfile do użycia podczas budowania.
  * --opt build-arg:BASE_VERSION=v2: Przekazuje argument budowy o nazwie BASE_VERSION.
  * --output type=image,name=ghcr.io/marekp21/pawcho6:lab6,push=true: Określa wyjście procesu budowania, w tym nazwę i lokalizację obrazu oraz opcję automatycznego przesłania obrazu do zdalnego rejestru.

<p align="justify">W procesie budowania nadano obrazowi tag <em>lab6</em>. Obraz został dodatkowo od razu przesłany do repozytorium na Github (repo: ghcr.io). Na poniższym rysunku widać wykonanie powyższego polecenia oraz fragment procesu budowania obrazu.</p><br> 
<p align="center">
  <img src="https://raw.githubusercontent.com/MarekP21/pawcho6/main/screeny/6. Budowanie obrazu z nadaniem tagu i przesłaniem na repozytorium GitHub.png" style="width: 80%; height: 80%" /></p>
<p align="center">
  <i>Rys. 6. Budowanie obrazu z nadaniem tagu i przesłaniem na repozytorium GitHub</i>
</p>

<p align="justify">W przeglądarce w zakładce packages na Githubie został zmieniony atrybut dostępu zbudowanego obrazu z private na public zgodnie z ostatnią częścią polecenia. Pokazane to zostało na poniższym rysunku.</p><br> 
<p align="center">
  <img src="https://raw.githubusercontent.com/MarekP21/pawcho6/main/screeny/7. Zmiana dostępu zbudowanego obrazu na public.png" style="width: 80%; height: 80%" /></p>
<p align="center">
  <i>Rys. 7. Zmiana dostępu zbudowanego obrazu na public</i>
</p>

---

### Uruchomienie kontenera i przetestowanie aplikacji
<p align="justify">Ostatecznie należało utworzyć i uruchomić kontener na bazie obrazu znajdującego się w zdalnym repozytorium. Do tego celu użyto polecenia analogicznego do tego z laboratorium 5, jednak obraz został pobrany bezpośrednio z repozytorium zdalnego, nie będąc dostępnym lokalnie. Stworzenie i uruchomienie kontenera widać na poniższym rysunku.</p><br>
<p align="center">
  <img src="https://raw.githubusercontent.com/MarekP21/pawcho6/main/screeny/8. Stworzenie i uruchomienie kontenera.png" style="width: 80%; height: 80%" /></p>
<p align="center">
  <i>Rys. 8. Stworzenie i uruchomienie kontenera</i>
</p>

<p align="justify">Pozostało jedynie sprawdzić w przeglądarce bądź z wykorzystaniem odpowiedniego polecenia, czy aplikacja działa prawidłowo. W tym celu wykorzystane zostało polecenie <em>curl</em>. Na poniższym zrzucie ekranu widać, że aplikacja działa zgodnie z założeniami i realizuje wymaganą funkcjonalność.</p><br>
<p align="center">
  <img src="https://raw.githubusercontent.com/MarekP21/pawcho6/main/screeny/9. Sprawdzenie działania aplikacji.png" style="width: 80%; height: 80%" /></p>
<p align="center">
  <i>Rys. 9. Sprawdzenie działania aplikacji</i>
</p>

---
