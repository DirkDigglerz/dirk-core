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

Post = function(type, data){
  $.post(`http://dirk-core/${type}`, JSON.stringify(data))
}
