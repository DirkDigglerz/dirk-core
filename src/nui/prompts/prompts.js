


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


let packages = [
  { name: 'Robbery Creator', value: 5203533, role: "1017079350677471242"},
  { name: 'Weed Growing', value: 5382654 },
  { name: 'Drug Dealers', value: 5382645 },
  { name: 'Bounty Hunting', value: 5382644 },
  { name: ' Drug labs V2', value: 5382659 },
  { name: 'Fishing Sim', value: 5382658 },
  { name: 'Bank truck + rob', value: 5382657 },
  { name: 'Fishing Sim - Open Source', value: 5109635 },
  { name: 'Robbery Creator OPEN SOURCE', value: 5286547 },
  { name: 'Player Owned Drug Labs', value: 5184177 },
  { name: 'Bank Truck Job + Robberies', value: 5183597 },
  { name: 'Bounty Hunting', value: 5326364 },
  { name: 'Drug Dealers', value: 5109509 },
  { name: 'Drug Labs V2', value: 5456503 },
  { name: 'Weed Growing', value: 5329056 },
  { name: 'Fishing Sim', value: 4955808 },
  { name: 'Burner Phone', value: 5773996 },
  { name: 'Crafting', value: 5469772 },
  { name: 'Drug Labs V2', value: 5861699 },
  { name: 'All in one pack', value: 5562897 }
]


getRoleFromPackageID = function(packageID){
  for (let i = 0; i < packages.length; i++){
    if (packages[i].value == packageID){
      return packages[i].role;
    }
  }
  return null;
}