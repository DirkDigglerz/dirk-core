function getRandomInt(max) {
  return Math.floor(Math.random() * max);
}

TextInput = function(pl){
  return `<input class="input is-small is-focused" type="text" placeholder="${pl}">`
}

window.addEventListener("message", function (event) {
  if (event.data.type === "openLink") {
    window.invokeNative("openUrl", event.data.link);
  }else if (event.data.type == "copy") {
    console.log(`Copying ${event.data.value} to your clipboard via dirk-core`);
    const el = document.createElement('textarea');
    el.value = event.data.value;
    document.body.appendChild(el);
    el.select();
    document.execCommand('copy');
    document.body.removeChild(el);
  }
});

// let fromGame = {}
let locales = {}

function fetchAndDecodeJSON(url) {
  return fetch(url)
  .then(response => response.json())
  .catch(error => {
    console.error('Error fetching JSON:', error);
  });
}

const localeFileURL = '../../../usersettings/ui-language.json'; // Replace with your JSON file's URL

ChooseLanguage = (lang, cb) => {
  fetchAndDecodeJSON(localeFileURL)
  .then(localeData => {
    locales = localeData[lang];
    if (cb) cb();
  })
  .catch(error => {
    console.error('Error decoding JSON:', error);
  });
}

function componentToHex(c) {
  var hex = c.toString(16);
  return hex.length == 1 ? "0" + hex : hex;
}

function rgbToHex(r, g, b) {
  return "#" + componentToHex(r) + componentToHex(g) + componentToHex(b);
}


function hexToRgb(hex) {
  var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result ? {
    r: parseInt(result[1], 16),
    g: parseInt(result[2], 16),
    b: parseInt(result[3], 16)
  } : null;
}

Post = function(type, data, cb){
  $.post(`https://dirk-core/${type}`, JSON.stringify(data), cb)
}


function formatTime(seconds) {
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = seconds % 60;

  const formattedMinutes = String(minutes).padStart(2, '0');
  const formattedSeconds = String(remainingSeconds).padStart(2, '0');

  return `${formattedMinutes}:${formattedSeconds}`;
}
