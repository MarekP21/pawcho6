const express = require('express');
const os = require("os");

const app = express();

app.get('/', (req, res) => {

  // Pobranie adresu IP serwera
  const ip = req.socket.localAddress;

  // Pobranie nazwy hosta
  const hostname = os.hostname();

  // Wysłanie odpowiedzi z informacjami
  res.send("Zadanie do wykonania - Laboratorium 5 - Marek Prokopiuk<br>" +
           "Adres IP serwera: " + ip + "<br>" +
           "Nazwa serwera (hostname): " + hostname + "<br>" +
           "Wersja aplikacji: " + process.env.APP_VERSION);
});

app.listen(8080, () => {
  console.log('Listening on port 8080');
});


