


ClosePrompt = function(){
  promptBox.animate({opacity:0}, 400, "easeOutCubic", function(){
    promptBox.remove();
  });
}


let Prompts = {};

AddPrompt = function(uniqueID, option){
  if (!Prompts[uniqueID]){
    let opt = $(`
      <promptOpt class="${option.click?"hover":""}">
        <div>
          ${option.icon?`<i class="${option.icon}"></i>`:""}
          <div>${option.label}</div>
        </div>
        ${option.subtext?`<div>${option.subtext}</div>`:""}
      </promptOpt>
    `).appendTo('prompt');

    Prompts[uniqueID] = opt;

    if (option.click){
      opt.click(function(){
        Post("click",{uniqueID: uniqueID});
      });
    }
    opt.animate({opacity:1}, 400, "easeOutCubic");
  }
}

RemovePrompt = function(uniqueID){
  if (Prompts[uniqueID]){
    let option = Prompts[uniqueID];
    option.animate({opacity:0}, 400, "easeOutCubic", function(){
      option.remove();
    });
    delete Prompts[uniqueID];
  }
}

window.addEventListener("message", function(event){
  let type = event.data.action;
  let data = event.data;
  if (type == "addOption"){
    AddPrompt(data.uniqueID, data.Option);
  }else if (type == "removeOption"){
    RemovePrompt(data.uniqueID);
  }
});
// setTimeout(function(){
//   ClosePrompt();
// }, 7600);


// OpenPrompt(options);

