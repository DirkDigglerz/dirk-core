

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
      $.post(`https://dirk-core/optionChosen`, JSON.stringify({
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
    $.post(`https://dirk-core/LoseFocus`)
  }
});

$(document).mousedown(function (event) {

  if (event.which == 3) {
    if (!Prompt) { return false; }
    Prompt = false;
    $.post(`https://dirk-core/LoseFocus`)
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
      $(`<div style="display:hidden;" id='row'>
          <div id='button'><kbd>${uppercase}</kbd></div>
          <div id='useinfo'>${value.label}</div>
        </div>
      `).appendTo(Current[event.data.name]).hide().fadeIn(200);
    });
  } else if (event.data.type == 'hide') {
    $(Current[event.data.name]).fadeOut(600, function () {
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


let curNotifications = {

}

let hasContainer = false;

DisplayNotification = function(data){
  if(!hasContainer){
    hasContainer = $(`<notifications></notifications>`).appendTo('body');
    // Position based on the following that will be passed as data.Position, topCenter, topLeft, topRight, bottomCenter, bottomLeft, bottomRight, center
    if (data.Position == "topCenter"){
      hasContainer.css({
        "top": "5%",
        "left": "50%",
      })
    }else if(data.Position == "topLeft"){
      hasContainer.css({
        "top": "5%",
        "left": "5%",
      })
    } else if(data.Position == "topRight"){
      hasContainer.css({
        "top": "5%",
        "right": "5%",
      })
    } else if(data.Position == "bottomCenter"){
      hasContainer.css({
        "bottom": "5%",
        "left": "50%",
      })
    } else if(data.Position == "bottomLeft"){
      hasContainer.css({
        "bottom": "5%",
        "left": "5%",
      })
    } else if(data.Position == "bottomRight"){
      hasContainer.css({
        "bottom": "5%",
        "right": "5%",
      })
    } else if(data.Position == "center"){
      hasContainer.css({
        "top": "50%",
        "left": "50%",
      })
    } 




  } 
  console.log("HERE")
  let initFormat = formatTime(data.Time);
  let newNotification = $(`
  <notification style="opacity:0;">
    <div>
      <i class="${data.Icon || "fas fa-exclamation-triangle"}"></i>
      <div>${data.Title || "Nothing"}</div>
    </div>
    <div>${data.Message}</div>
    ${!data.NoTimer?`
    <div>
      <div>${initFormat}</div>
    </div>
    `:""}
  </notification>`).appendTo('notifications');


  newNotification.animate({ opacity: 1 }, 500);
  curNotifications[data.ID] = newNotification;

  if (data.NoTimer) return;
  let progBarinner = newNotification.find('div:nth-child(3) div');
  progBarinner.css('width', '100%');
  progBarinner.animate({
    width: '0%',
  },  data.Time * 1000, 'linear', function(){
    newNotification.animate({ opacity: 0 }, 500, function(){
      newNotification.remove();
      delete curNotifications[data.ID];
    });
   
  })


  let thisTimer = setInterval(function(){
    if (!curNotifications[data.ID]) return clearInterval(thisTimer);
   

    data.Time = data.Time - 1;
    progBarinner.text(formatTime(data.Time));
    if (data.Time == 0) return clearInterval(thisTimer);
  }, 1000)


}



window.addEventListener('message', function(event){
  if (event.data.type == "DisplayNotification"){
    DisplayNotification(event.data.data);
  } else if (event.data.type == "RemoveNotification"){
    let thisNotification = curNotifications[event.data.ID]
    if (thisNotification){
      thisNotification.animate({ opacity: 0 }, 500, function(){
        thisNotification.remove();
        delete curNotifications[event.data.ID];
      });
    }
  }
})
