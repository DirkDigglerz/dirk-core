function getRandomInt(max) {
  return Math.floor(Math.random() * max);
}

TextInput = function(pl){
  return `<input class="input is-small is-focused" type="text" placeholder="${pl}">`
}