let cache = {};

let fromGame = {
  Currency: "$",
  Language: "ENG",
  Store: {
    Name: "Dirks Underground Dealer",
    ID: "dirk",
    Icon: "fas fa-store",

    Items: [
      {
        Name: "weapon_pistol",
        Label: "Pistol",
        Price: 100,
        Img: "https://i.ibb.co/qCqcnH3/CIGAR-APE-IN-SPACE1111.png", 
      },
    ]
  }
}

let myBasket = {
  "Name": "Dirks Underground Dealer",
  "ID": "dirk",
  "Items":{
    "weapon_pistol": {
      Name: "weapon_pistol",
      Label: "Pistol",
      Img: "https://i.ibb.co/qCqcnH3/CIGAR-APE-IN-SPACE1111.png",
      Price: 500,
      Amount: 5,
    },
  },
}



UpdateBasketTotal = function(){
  // UPDATE BOTTOM BAR
  basketTotal = $('.currentTotal');
  let newTotal = 0;
  for (let i = 0; i < Object.keys(myBasket.Items).length; i++) {
    let item = myBasket.Items[Object.keys(myBasket.Items)[i]];
    newTotal += item.Price;
  }
  basketTotal.text(`${fromGame.Currency}${newTotal} `);
}

AddToBasket = function(item, amount){
  console.log("ADDING")
  console.log(JSON.stringify(item, null, 2))
  if (myBasket.Items[item.Name]){
    myBasket.Items[item.Name].Amount += amount;
    myBasket.Items[item.Name].Price = item.Price * myBasket.Items[item.Name].Amount;
    let basketItem = $(`#basketItem_${item.Name}`);
    basketItem.find('#amountText').text(myBasket.Items[item.Name].Amount);
    basketItem.find('#prodPrice').text(`${fromGame.Currency} ${item.Price * myBasket.Items[item.Name].Amount}`);

  } else {
    myBasket.Items[item.Name] = {
      Name: item.Name,
      Label: item.Label,
      Price: item.Price * amount,
      Img: item.Img,
      Amount: amount,
    }

    let basketCont = openStore.find('basketContent');
    let itemEl = $(`
      <storeItem id="basketItem_${item.Name}">
        <div id="prodName">${item.Label}</div>
        <div id="prodImg"></div>

        <div id="amountGroup" class ="row">
          <div id="amountText">${amount}</div>
        </div>

        <div id="removeButtonGroup" class ="row">
          <div id="prodPrice">${fromGame.Currency} ${myBasket.Items[item.Name].Price}</div>

          <div id="removeButton" class="row">
            <i>${locales.Remove}</i>
            <i  class="fas fa-minus"></i>
          </div>
        </div>
      </storeItem>
    `).appendTo(basketCont);
    itemEl.find('#prodImg').css('background-image', `url('nui://${item.Img}')`);
    itemEl.find('#removeButton').click(function(){
      itemEl.fadeOut(200, function(){
        itemEl.remove();
        delete myBasket.Items[item.Name];
        UpdateBasketTotal();
      });
      
    });
  }
  UpdateBasketTotal();
}

BuildBasket = function(){
  for (let i = 0; i < Object.keys(myBasket.Items).length; i++) {
    let item = myBasket.Items[Object.keys(myBasket.Items)[i]];
    let basketCont = openStore.find('basketContent');
    let itemEl = $(`
      <storeItem id="basketItem_${item.Name}">
        <div id="prodName">${item.Label}</div>
        <div id="prodImg"></div>

        <div id="amountGroup" class ="row">
          <div id="amountText">${item.Amount}</div>
        </div>

        <div id="removeButtonGroup" class ="row">
          <div id="prodPrice">${fromGame.Currency} ${myBasket.Items[item.Name].Price}</div>

          <div id="removeButton" class="row">
            <i>${locales.Remove}</i>
            <i  class="fas fa-minus"></i>
          </div>
        </div>
      </storeItem>
    `).appendTo(basketCont);
    itemEl.find('#prodName').text(item.Label);
    itemEl.find('#prodImg').css('background-image', `url('nui://${item.Img}')`);
    itemEl.find('#prodPrice').text(`${fromGame.Currency} ${item.Price}`);
    itemEl.find('#removeButton').click(function(){
      itemEl.fadeOut(200, function(){
        itemEl.remove();
        delete myBasket.Items[item.Name];
        UpdateBasketTotal();
      });
      
    });
  }
  UpdateBasketTotal();
}

storeFront = function(){
  if (myBasket.Name != fromGame.Store.Name){
    myBasket = {
      "Name": fromGame.Store.Name,
      "ID": fromGame.Store.ID,
      "Items":{},
    }
  }



  openStore = $(`
  <storeContainer style="opacity:0;">
    <storeFront>
      <storeTitleBar class="row">
        <i class="rowIcon greyText ${fromGame.Store.Icon}"></i> 
        <div class="rowText">${fromGame.Store.Name}</div>

      </storeTitleBar>

      <storeContent class="grid">
      </storeContent>

    </storeFront>
  
    <storeBasket>
      <div class="row basketTitle">
        <i class="rowIcon greyText ${fromGame.Store.Icon}"></i> 
        <div class="rowText">${locales.Basket}</div>
      </div>

      <basketContent></basketContent>
      <basketFooter class="row">
        <div class="row">
          <div class="rowText">${locales.Total}:</div>
          <div class="rowText currentTotal">${fromGame.Currency} 100</div>      
        </div>
        <div class="row" id="checkOutButton">
          <div class="rowText">${locales.Purchase}</div>
          <div><i class="fas fa-money-bill-wave"></i></div>
        </div>
      </basketFooter>
    </storeBasket>
  </storeContainer>
    
  `).appendTo('body');
  
  let itemCont = openStore.find('storeContent');
  for (let i = 0; i < fromGame.Store.Items.length; i++) {
    let item = fromGame.Store.Items[i];
    let itemEl = $(`
      <storeItem>
        <div id="prodName">Gang Token</div>
        <div id="prodImg"></div>

        <div id="amountGroup" class ="row">
          <i id ="amountMinus" class="fas fa-minus"></i>
          <div id="amountText">1</div>
          <i id="amountPlus" class="fas fa-plus"></i>
        </div>

        <div id="addToBasketGroup" class ="row">
          <div id="prodPrice">${fromGame.Currency} 100</div>

          <div id="addToBasket" class="row">
            <i>Add</i>
            <i  class="fas fa-shopping-basket"></i>
          </div>
          
        </div>

      </storeItem>
    `).appendTo(itemCont);
  
    itemEl.find('#prodName').text(item.Label);
    itemEl.find('#prodImg').css('background-image', `url('nui://${item.Img}')`);
    itemEl.find('#prodPrice').text(`${fromGame.Currency} ${item.Price}`);
  
    itemEl.find('#addToBasket').click(function(){
      let amountToAdd = parseInt(itemEl.find('#amountText').text());

      AddToBasket(item, amountToAdd);
    });

    itemEl.find('#amountMinus').click(function(){
      let amount = parseInt(itemEl.find('#amountText').text());
      if (amount > 1){
        itemEl.find('#amountText').text(amount - 1);
        itemEl.find('#prodPrice').text(`${fromGame.Currency} ${item.Price * (amount - 1)}`);
      }

    });

    itemEl.find('#amountPlus').click(function(){
      let amount = parseInt(itemEl.find('#amountText').text());
      itemEl.find('#amountText').text(amount + 1);
      itemEl.find('#prodPrice').text(`${fromGame.Currency} ${item.Price * (amount + 1)}`);
      // UPDATE BOTTOM BAR

    });



  }

  $('#checkOutButton').click(function(){
    console.log("CHECKOUT")
    console.log(JSON.stringify(myBasket, null, 2))
    Post("checkOut", myBasket, function(hasMoney){
      if (hasMoney){
        myBasket = {
          "Name": fromGame.Store.Name,
          "ID": fromGame.Store.ID,
          "Items":{},
        }
        openStore.fadeOut(200, function(){
          openStore.remove();
          openStore = null;
          Post("closeStore", {ID: fromGame.Store.ID})
        });
      } else {
        alert("You dont have enough money")
      }
    });
  });
  BuildBasket();

  openStore.animate({opacity: 1}, 200);
}

// ChooseLanguage(fromGame.Language, function(){
//   storeFront();
// })

// listen for escape key 
document.addEventListener('keyup', function(e) {
  if (e.key === "Escape") {
    if (openStore){
      openStore.animate({opacity: 0}, 200, function(){
        openStore.remove();
        openStore = null;
        Post("closeStore", {ID: fromGame.Store.ID})
      });
    }
  }
});

window.addEventListener('message', function(event) {
  let data = event.data;
  if (data.type == "openStore") {
    fromGame = data.fromGame;
    ChooseLanguage(fromGame.Language, function(){
      storeFront();
    })

  }
});