let curNotifications = {};
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



// MULTI SELECT/SINGLE SELECT MENU

let curSelectMenu = false;
let canCancel = false;
let openSelectMenu = function (items, multi, title, icon, cancel) {
  canCancel = cancel;
  curSelectMenu = $(`<div class="selectMenu">
    <div class="selectMenuHeader">
      <i class="${icon}"></i>
      <div>${title}</div>
    </div>
    <div class="selectMenuItems"></div>
    <div class="selectMenuFooter">
      <div class="confirmSelectMenu">
        <i class="fas fa-check"></i>
        <div>Confirm</div>
      </div>
    </div>
  </div>`).appendTo('body');


  let confirmButton = curSelectMenu.find('.confirmSelectMenu');
  confirmButton.click(function () {
    let selectedItems = [];
    for (let k in items) {
      let item = items[k];
      if (item.selected) {
        selectedItems.push(item.value);
      }
    }
    curSelectMenu.fadeOut(200, function () {
      curSelectMenu.remove();
      curSelectMenu = false;
      console.log(JSON.stringify(selectedItems));
      $.post(`https://dirk-core/selectMenuReturn`, JSON.stringify(selectedItems));
    });
  

  });

  for (let k in items) {
    let item = items[k];
    let newItem = $(`<div class="selectMenuItem ${item.selected?'selectedItem':''}">
      <i class="${item.icon}"></i>
      <div>${item.label}</div>
  
      ${multi && item.selected ? `<i class="fas fa-check checkBox"></i>` : ""}
    </div>`).appendTo('.selectMenuItems');

    $(newItem).click(function () {
      if (multi) {
        if (item.selected) {
          item.selected = false;
          $(this).find('.checkBox').css('opacity', '0');
          $(this).removeClass("selectedItem");
        } else {
          item.selected = true;
          $(this).find('.checkBox').css('opacity', '1');
          $(this).addClass("selectedItem");
        }
      } else {
       
        for (let k in items) {
          let item = items[k];
          item.selected = false;
        }
        item.selected = true;
        $(this).addClass("selectedItem");
        $(this).siblings().removeClass("selectedItem");
      }
    })
  }
}

// openSelectMenu([
//   {label: "Super Rare", icon: "fas fa-exclamation-triangle", value: "test", selected : true},
//   {label: "Rare ", icon: "fas fa-exclamation-triangle", value: "test2", selected : false},
// ], false, "Select Loottable", "fas fa-dollar-sign", true);

// Listen for escape key 
$(document).on('keydown', function (event) {
  if (event.key == "Escape") {
    if (!curSelectMenu) { return false; }
    if (!canCancel) { return false; }
    // Probably close any sub menu
    curSelectMenu.fadeOut(200, function () {
      curSelectMenu.remove();
      curSelectMenu = false;
    });

    
    $.post(`https://dirk-core/closeSelectMenu`, JSON.stringify({}));
  }
});

window.addEventListener('message', function (event) {
  if (event.data.type == "openSelectMenu"){
    openSelectMenu(event.data.items, event.data.multi, event.data.title, event.data.icon, event.data.canCancel);
  }
})


// ADVANCED HELP NOTIF
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






// SELECT ITEMS GRID BOX


let itemSelectionOpen = false;
let currentSelection = [];


let deepEqual = function(obj1, obj2) {
  if (obj1 === obj2) {
    return true;
  }

  if (typeof obj1 !== 'object' || obj1 === null || typeof obj2 !== 'object' || obj2 === null) {
    return false;
  }

  const keys1 = Object.keys(obj1);
  const keys2 = Object.keys(obj2);

  if (keys1.length !== keys2.length) {
    return false;
  }

  for (let key of keys1) {
    if (!keys2.includes(key) || !deepEqual(obj1[key], obj2[key])) {
      return false;
    }
  }

  return true;
}

let findInSelection = function(item){
  for (let k in currentSelection){
    let curItem = currentSelection[k];
    if (curItem.name == item.name){
      if (!curItem.metadata && !item.metadata) return k;
      if (!curItem.metadata && item.metadata) return false;
      if (curItem.metadata && !item.metadata) return false;
      if (deepEqual(curItem.metadata, item.metadata)) {
        return k;
      }
    }
  }
  return false;
}

let addToSelection = function(item){
  let found = findInSelection(item);
  if (found !== false){
    currentSelection[found].count = currentSelection[found].count + 1;
  } else {
    currentSelection.push(item);
  }
}

let removeFromSelection = function(item){
  let found = findInSelection(item);
  if (found !== false){
    currentSelection[found].count = currentSelection[found].count - 1;
    if (currentSelection[found].count <= 0){
      currentSelection.splice(found, 1);
    }
  }
}








itemSelection = function(items, settings){
  itemSelectionOpen = $(`
    <itemSelection>
      <itemSelectionHeader>
        <i class="${settings.icon}"></i>
        <div>${settings.header}</div>
      </itemSelectionHeader>
      <itemSelectionItems></itemSelectionItems>
    </itemSelection>
  `).appendTo('body');
  
  let itemSelectionItems = itemSelectionOpen.find('itemSelectionItems');
  for (let k in items){
    let item = items[k];
    let newItem = $(`
      <itemSquare>
        <itemLabel></itemLabel>
      </itemSquare>
    `).appendTo(itemSelectionItems);
    
    newItem.mousedown(function(event) {
      switch (event.which) {
        case 1:
          alert('Left Mouse button pressed.');
          // ADD TO CURRENT SELECTION AND ENSURE THIS ITEM IS HIGHLIGHTED ASWELL AS ADDING TO THE COUNTER IN THE TOP RIGHT
          
          break;
        case 3:
          alert('Right Mouse button pressed.');
          // REMOVE FROM CURRENT SELECTION AND ENSURE THIS ITEM IS NO LONGER HIGHLIGHTED ASWELL AS REMOVING FROM THE COUNTER IN THE TOP RIGHT IF THE SELECTED COUNT IS BELOW 1 
          break;
        default:
          alert('You have a strange Mouse!');
      }
    });
  } 
}

// itemSelection([
//   {
//     name:'bread',
//     label:'Bread',
//     image:'https://i.imgur.com/6Jh2vYd.png',
//     count:5, 
//     metadata:{},
//   }
// ],{
//   multiple:false,
//   header:'Select Item',
//   icon:'fas fa-dollar-sign',
// })