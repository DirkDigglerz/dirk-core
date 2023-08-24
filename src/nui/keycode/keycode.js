
OpenKeyPad = function(Code, data){
  console.log("here");
  let KeyPanel = $(`
    <div class="Panel">
      <div class="brand">Security Panel 3000</div>
      <div class="Screen"></div>
      <div class="Keys">
        <div class="Key" onclick="ButtonPress(7)">7</div>
        <div class="Key" onclick="ButtonPress(8)">8</div>
        <div class="Key" onclick="ButtonPress(9)">9</div>
        <div class="Key" onclick="ButtonPress(4)">4</div>
        <div class="Key" onclick="ButtonPress(5)">5</div>
        <div class="Key" onclick="ButtonPress(6)">6</div>
        <div class="Key" onclick="ButtonPress(1)">1</div>
        <div class="Key" onclick="ButtonPress(2)">2</div>
        <div class="Key" onclick="ButtonPress(3)">3</div>
        <div class="Key" onclick="ButtonPress(0)">0</div>

      </div>
    </div>
  `).appendTo('body');




  // Cancel + Confirm Buttons


  $(`<div class="Key" style="color:red;"><i class="fa-solid fa-delete-left"></i></div>`).appendTo('.Keys').click(function(){
    let curText = $('.Screen').text();
    let newText = curText.substring(0, curText.length - 1)
    $('.Screen').text(newText)
  })

  $(`<div class="Key" style="color:green;"><i class="fa-solid fa-circle-check"></i></div>`).appendTo('.Keys').click(function () {
    let curText = Number($('.Screen').text());
    if (curText == Code){
      $('.Screen').css("background-color", "green");
      setTimeout(() => {
        $('.Screen').css("background-color", "aliceblue");
      }, 500);

      // Post Complete
      ClosePanel(true);



    }else{
      $('.Screen').css("background-color", "red");
      setTimeout(() => {
        $('.Screen').css("background-color", "aliceblue");
      }, 500);

      if (!data.multipleTries){
        // Post and Close
        ClosePanel(false);
      }

    }
  })


  setTimeout(() => {
    $('.Panel').css("opacity", "1");
  }, 100);
}

ButtonPress = function(n){
  $('.Screen').text(`${$('.Screen').text()}${n}`)
}

ClosePanel = function(s){
  $('.Panel').css("opacity", "0");
  setTimeout(() => {
    $('body').empty();
    $.post(`https://dirk-core/keyCodeResponse`, JSON.stringify({
      correct: s,
    }))

  }, 750);
}






window.addEventListener("message", function (event) {
  if (event.data.type === "openKeyPad") {
    Code = event.data.code;
    OpenKeyPad(Code, event.data.params)
  }
});