let testOpen = false;

window.addEventListener("message", function (event) {
  if (event.data.action === "openLicenseTest") {
    if (testOpen) return;
    openLicenseTest(event.data.title, event.data.minPass, event.data.questions)
  }
});


openLicenseTest = function (licenseName, minPass, questions) {
  testOpen = true;
  let container = $(`<div class="questionPanel" style="opacity:1;">
    <div class="questionPanelTitle">${licenseName}</div>
  </div>`).appendTo('body');
  let content = $(`<div class="questionPanelContent"></div>`).appendTo(container);

  for (let k in questions){
    let q = questions[k];
    let qContainer = $(`<div class="questionContainer">
      <div class="question">
        <i class="fa-solid fa-circle-question"></i>
        <div>${q.question}</div>
      </div>
      <div class="answers"></div>
    </div>`).appendTo(content);
    let answerBox = qContainer.find('.answers');
    for (let k in q.answers){
      let a = q.answers[k];
      let answer = $(`<div class="answer">
        <i class="fa-solid fa-square"></i>
        <div>${a.answer}</div>
      </div>`).appendTo(answerBox);

 
      answer.click(function(){
        if (q.answered != null || q.answered != undefined) return;
        q.answered = a.correct;
        if (answer.hasClass('selected')) return;
        answerBox.find('.answer').removeClass('selected');
        answer.addClass('selected');
        if (a.correct){
          answer.addClass('correct');
          answer.find('i').removeClass('fa-square').addClass('fa-square-check');
        } else {
          answer.addClass('incorrect');
          answer.find('i').removeClass('fa-square').addClass('fa-square-xmark');
        }

        let correctAnswers = 0
        for (let k in questions){
          let q = questions[k];
          if (q.answered == null || q.answered == undefined) return;
          if (q.answered == true){correctAnswers++}
        }
        let result = "Fail"
        if (correctAnswers >= minPass){
          result = "Pass"
        }
        testOpen = false;
        container.fadeOut(500, function(){
          container.remove();
          Post('testResult', {result:result})
        })
       
      })
    }
  }
}




// openLicenseTest("Hunting License", 1, [
//   {
//     question: "What is the minimum caliber for hunting deer?",
//     answers: [
//       {
//         answer: "9mm",
//         correct: false,
//       },
//       {
//         answer: ".22",
//         correct: true,
//       },
//       {
//         answer: ".223",
//         correct: false,
//       },
//     ],
//   },
//   {
//     question: "Lets have a really logn question so we can test the bounds of this box cause I am not sure how long it will stretch for its kind of weird",
//     answers: [
//       {
//         answer: "9mm",
//         correct: false,
//       },
//       {
//         answer: ".22",
//         correct: false,
//       },
//       {
//         answer: ".223",
//         correct: false,
//       },
//     ],
//   },
// ])