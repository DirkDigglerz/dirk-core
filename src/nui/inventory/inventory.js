

// PASS THIS DATA
let ShopsEnabled = true
let inventoryItems = [
  {
    id: "Player",
    label: "My Inventory",
    items: [
      {
        name: "bread",
        label: "Bread",
        count: 1,
        info: {
          Stale: true,
          'Date of Prod': 'June 5th',
        },
      },

      // {
      //   name: "something",
      //   label: "Test",
      //   count: 4,
      // },

    ],
  },
  {
    id: "LabInventory",
    label: "Drug Lab",
    items: [
      {
        name: "bread",
        label: "Bread",
        count: 1,
        info: {
          Stale: true,
          'Date of Prod': 'June 5th',
        },
      },

      {
        name: "something",
        label: "Test",
        count: 4,
      },

    ],
  },
]
// PASSED

MakeItemEditorPage = function(item,inv){
  let ManagePage = $(`<div class="ManagePage"></div>`).appendTo('body')

  $(ManagePage).css("opacity","1.0");

  let ManageTitle = $(`<div class="ManageTitle">Edit Item</div>`).appendTo(ManagePage);

  let SaleOptTitle = $(`<div class="optLabel">Selling</div>`).appendTo(ManagePage);
  let SaleOpt = $(`<input class="toggleRadial is-normal" type="checkbox">`).appendTo(ManagePage);

  let SalePriceTitle = $(`<div class="optLabel">Sale Price</div>`).appendTo(ManagePage);
  let PriceOpt = $(`<input type="number">`).appendTo(ManagePage);

  let MinStockTitle = $(`<div class="optLabel">Min Stock Limit</div>`).appendTo(ManagePage);
  let MinStockOpt = $(`<input type="number">`).appendTo(ManagePage);

  let buttons = $(`<div style="margin-top:15px; font-size:100%;" class="buttonRow"></div>`).appendTo(ManagePage);

  let BackButton   = $(`<i style="font-size:110%" id="backButton1" class=" buttons fa-solid fa-rotate-left"></i>`).appendTo(buttons);

  $(BackButton).click(function(){
    $(ManagePage).css("opacity", "0.0")
    setTimeout(function(){
      $(ManagePage).remove();
    }, 250)

  })

  tippy(`#backButton1`, {
    arrow:false,
    content: 'Go back',
    animation:'fade',
    theme:'dirk',
    placement:'right',
  });

  let SaveButton = $(`<i   style="font-size:110%"  id="saveSettings" class="buttons fa-solid fa-dumpster"></i>`).appendTo(buttons);
  $(SaveButton).click(function(){
    // POST TO FIVEM
  })


  tippy(`#saveSettings`, {
    arrow:false,
    content: 'Save new settings.',
    animation:'fade',
    theme:'dirk',
    placement:'right',
  });

}



let Container = false;

let currentCount = 1;
let imageDir = ""
function makeid(length) {
  var result = '';
  var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  var charactersLength = characters.length;
  for (var i = 0; i < length; i++) {
    result += characters.charAt(Math.floor(Math.random() * charactersLength));
  }
  return result;
}


let indexItems = [
  {},
  {}
]

MakeItemBox = function(d, g, invName){
  let uid = `${makeid(3)}`
  console.log(JSON.stringify(d))
  console.log(invName)
  let Item = $(`<div class="InvItem" id="${uid}">
    <div class="ItemCount">${d.count}</div>
    <div class="ItemTitle">${d.label}</div>
  </div>`).appendTo(g);
  $(Item).css("background-image", `url(nui://${imageDir}${d.name}.png)`)
  $(Item).click(function(){
  })


  $(Item).data('iData', d); //setter
  $(Item).data('origin', invName)
  $(Item).data('uid', uid)

  // if (invName == "OtherInv" && ShopsEnabled){
  //   $(Item).dblclick(function(){
  //     MakeItemEditorPage(item, invName)
  //   })
  // }

  if (d.info != null){
    let cont = '';
    Object.entries(d.info).forEach(entry => {
      const [k, v] = entry
      cont = `${cont}<div>${k} : ${v}</div>`
    })

    tippy(`#${uid}`, {
      arrow: false,
      content: cont,
      animation: 'fade',
      theme: 'dirk',
      placement: 'right',
      allowHTML: true,
    });

    indexItems[uid] = Item

  }


  let data = {
    helper:'clone',
    revert: "invalid",
    start: function(e) {
      memo = $(this).css('transition');
      $(this).css('transition', 'none');
      $(this).data('iData', d); //setter
      $(this).data('origin',invName)
      $(this).data('uid',uid)

    },
    stop: function() {
      $(this).css('transition', memo);
    }
  }

  $(Item).draggable(data);

  return Item

}



OpenInventories = function(){
  let inv1 = inventoryItems[0]
  let inv2 = inventoryItems[1]
  Container = $(`<div class="InvContainer"></div>`).appendTo('body');




  let CountBox = $(`<div class="countBox"></div>`).appendTo(Container);
  let CountLabel = $(`<div class="countLabel">Transfer Count</div>`).appendTo(CountBox);
  let Count = $(`<input class="count" type="number" id="tentacles" name="tentacles"
       min="1" max="99999" placeholder = "1">`).appendTo(CountBox);

  $(Count).on("input", function () {
    currentCount = $(this).val();
  })



  let MyInv = $(`<div class="MyInv"></div>`).prependTo(Container);
  let MyInvTitle = $(`<div class="InvTitle">${inv1.label}</div>`).appendTo(MyInv);
  let MyInvGrid = $(`<div class="InvGrid"></div>`).appendTo(MyInv);
  // INJECTS ALL ITEMS INTO THIS INVENTORY
  Object.entries(inv1.items).forEach(entry => {
    const [item, d] = entry;
    MakeItemBox(d, MyInvGrid, 0);
  })


  $(MyInvGrid).droppable({
    drop: function (event, ui) {

      let itemOrigin = $(ui.draggable).data('origin');
      let itemIndex = $(ui.draggable).data('index');
      let iData = $(ui.draggable).data('iData');

      if (itemOrigin == 0){ // Revert if trying to drag to same inventory.
        ui.draggable.draggable('option', 'revert', true);
        ui.draggable.draggable('option', 'revert', 'invalid');
        return
      }

      if (currentCount > iData.count){ // Return false if trying to move across too many
        $(ui.draggable).find(".ItemCount").css("color", "red")
        setTimeout(() => {
          $(ui.draggable).find(".ItemCount").css("color", "white")
        }, 1250);
        return
      }


      if (iData.info){
        $(ui.draggable).remove();
        MakeItemBox(iData, MyInvGrid, 0)
      }


      if (!iData.info){
        if(Number(iData.count) == Number(currentCount)){
          $(ui.draggable).remove();
          // Removing old one because we are taking it all
        }else{
          $(ui.draggable).find(".ItemCount").text(iData.count - currentCount)
          iData.count = Number(iData.count) - Number(currentCount)
          $(ui.draggable).data("iData", iData)
          let test = $(ui.draggable).data("iData");
          // Editing count of old because we are not taking it all
        }


        let Added = false;
        // Check if we need to make a new tile in the inventory or if we can edit an existing count
        let MyInvItems = $(MyInvGrid).children()
        MyInvItems.each(function (k, v) {
          let itemData = $(v).data("iData");
          if (!itemData.info && itemData.name == iData.name) {
            let newCount = Number(itemData.count) + Number(currentCount)
            $(v).find(".ItemCount").text(`${newCount}`)
            itemData.count = newCount
            $(v).data("iData", itemData)
            Added = true;
          }
        })

        if (!Added) {
          let copyData = Object.assign({}, iData)
          copyData.count = currentCount
          MakeItemBox(copyData, MyInvGrid, 0)
        }
      }


      $.post(`http://dirk-core/TransferInventory`, JSON.stringify({
        Source: inv2.id,
        Target: inv1.id,
        Item: {
          'name': iData.name,
          'count': currentCount,
          'info': iData.info || null,
          'label': iData.label,
        },
      }))
      // POST HERE TRANSFER FROM MYINV TO OTHER INV

    }
  })



  /// RIGHT HAND SIDE INVENTORY

  let RightInv = $(`<div class="MyInv"></div>`).appendTo(Container);
  let RightInvTitle = $(`<div class="InvTitle">${inv2.label}</div>`).appendTo(RightInv);
  let RightInvGrid = $(`<div class="InvGrid"></div>`).appendTo(RightInv);

  // INJECTS ALL ITEMS INTO THIS INVENTORY
  Object.entries(inv2.items).forEach(entry => {
    const [item, d] = entry;
    MakeItemBox(d, RightInvGrid, 1);
  })

  $(RightInvGrid).droppable({
    drop: function (event, ui) {
      let itemOrigin = $(ui.draggable).data('origin');
      let itemIndex = $(ui.draggable).data('index');
      let iData = $(ui.draggable).data('iData');

      if (itemOrigin == 1) { // Revert if trying to drag to same inventory.
        ui.draggable.draggable('option', 'revert', true);
        ui.draggable.draggable('option', 'revert', 'invalid');
        return
      }

      if (currentCount > iData.count) { // Return false if trying to move across too many
        $(ui.draggable).find(".ItemCount").css("color", "red")
        setTimeout(() => {
          $(ui.draggable).find(".ItemCount").css("color", "white")
        }, 1250);
        return
      }


      if (iData.info) {
        $(ui.draggable).remove();
        MakeItemBox(iData, RightInvGrid, 1)
      }


      if (!iData.info) {
        if (Number(iData.count) == Number(currentCount)) {
          $(ui.draggable).remove();
          // Removing old one because we are taking it all
        } else {
          $(ui.draggable).find(".ItemCount").text(iData.count - currentCount)
          iData.count = Number(iData.count) - Number(currentCount)
          $(ui.draggable).data("iData", iData)
          let test = $(ui.draggable).data("iData");
          // Editing count of old because we are not taking it all
        }


        let Added = false;
        // Check if we need to make a new tile in the inventory or if we can edit an existing count
        let RightInvItems = $(RightInvGrid).children()
        RightInvItems.each(function (k, v) {
          let itemData = $(v).data("iData");
          if (!itemData.info && itemData.name == iData.name) {
            let newCount = Number(itemData.count) + Number(currentCount)
            $(v).find(".ItemCount").text(`${newCount}`)
            itemData.count = newCount
            $(v).data("iData", itemData)
            Added = true;
          }
        })

        if (!Added) {
          let copyData = Object.assign({}, iData)
          copyData.count = currentCount
          MakeItemBox(copyData, RightInvGrid, 1)
        }
      }


      $.post(`http://dirk-core/TransferInventory`, JSON.stringify({
        Source: inv1.id,
        Target: inv2.id,
        Item: {
          'name': iData.name,
          'count': currentCount,
          'info': iData.info || null,
          'label': iData.label,
        },
      }))
      // POST HERE TRANSFER FROM MYINV TO OTHER INV

    }
  })





  $(Container).css("opacity", "1.0");
}

let inventoryOpen = false;

CloseInventory = function(){
  inventoryOpen = false;
  $(Container).css("opacity", "0.0")
  setTimeout(function(){
    $(Container).remove();
  },250)
}

$(document).on('keydown', function(e) {
  if (e.key == "Escape"){
    if (inventoryOpen){
      CloseInventory()
      $.post(`http://dirk-core/CloseInventory`, JSON.stringify({
        CurrentInventory: curInvID,
      }))
    }
  }
});

window.addEventListener("message", function(event) {
  if (event.data.type === "openInventory") {
    inventoryOpen = true
    curInvID = event.data.inventories[1].id;
    imageDir   = event.data.imageDir;
    inventoryItems = event.data.inventories;
    OpenInventories();
  }
});

// OpenInventory("Drug Lab Cocaine", inventoryItems, false)