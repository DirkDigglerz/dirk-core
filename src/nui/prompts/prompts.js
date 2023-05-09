

let currentPrompts = {}
let Prompt = false
OpenPrompt = function (id, options, x, y) {

  currentPrompts[id] = $(`<div class="promptList"></div>`).appendTo('body').css({
    "left": `${x}%`,
    "top": `${y}%`,
  })

  Object.entries(options.Buttons).forEach(entry => {
    const [typeid, data] = entry;
    console.log(data.button)
    $(`
      <div class="Prompt">
        <div class="promptButton">${data.button}</div>
        <div class="promptText">${data.text}</div>
      </div>
    `).appendTo(currentPrompts[id]);

  })

  Object.entries(options.ClickOptions).forEach(entry => {
    const [typeid, data] = entry;
    let Clickable = $(`
      <div class="Prompt">
        <div class="icon"><i class="${data.icon}"></i></div>
        <div class="promptText">${data.text}</div>
      </div>
    `).appendTo(currentPrompts[id]);



    $(Clickable).click(function () {
      console.log('Clicked')
      $.post(`http://dirk-core/optionChosen`, JSON.stringify({
        id: id,
        type: "ClickOptions",
        typeid: typeid,
        ent: options.Ent,
      }))
    })
  })






}


ClosePrompt = function (id) {
  $(currentPrompts[id]).remove();
  delete currentPrompts[id]
}




$(document).on('keydown', function (event) {

  if (event.key == "Escape") {
    if (!Prompt) { return false; }
    // Probably close any sub menu
    Prompt = false;
    $.post(`http://dirk-core/LoseFocus`)
  }
});

$(document).mousedown(function (event) {

  if (event.which == 3) {
    if (!Prompt) { return false; }
    Prompt = false;
    $.post(`http://dirk-core/LoseFocus`)
  }
});

var Current = {}
var HelpOpen = false;

window.addEventListener('message', function (event) {
  if (event.data.type == "show") {
    if (Object.keys(Current).length === 0){
      $(`<div class="HelpOuter"></div>`).appendTo('body')
    }
    Current[event.data.name] = $(`<div id="HelpContainer"></div>`).appendTo(".HelpOuter");
    $.each(event.data.message, function (index, value) {
      var raw = value.key
      var uppercase = raw.toUpperCase();
      $(`<div id='row'>
          <div id='button'><kbd>${uppercase}</kbd></div>
          <div id='useinfo'>${value.label}</div>
        </div>
      `).appendTo(Current[event.data.name]);
    });
  } else if (event.data.type == 'hide') {
    $(Current[event.data.name]).fadeOut(1000, function () {
      console.log('Finsiehd')
      $(Current[event.data.name]).remove();
    });

    delete Current[event.data.name]
    if (Object.keys(Current).length === 0) {
      $('.HelpOuter').remove();
    }

  }
})


window.addEventListener("message", function (event) {

  if (event.data.type === "displayPrompt") {

    if (currentPrompts[event.data.id]) {
      if (event.data.promptChange) {
        ClosePrompt(event.data.id)
        OpenPrompt(event.data.id, event.data.options, event.data.x, event.data.y)
      } else {
        $(currentPrompts[event.data.id]).css("left", `${event.data.x}%`)
        $(currentPrompts[event.data.id]).css("top", `${event.data.y}%`)
      }


    } else {
      console.log("Displaying", event.data.id)
      OpenPrompt(event.data.id, event.data.options, event.data.x, event.data.y)
    }
  } else if (event.data.type === "closePrompt") {
    ClosePrompt(event.data.id)
  } else if (event.data.type === "promptFocus") {
    Prompt = true;
  }
});
