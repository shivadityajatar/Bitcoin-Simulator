// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channelsList, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket} from "phoenix"


var socketsList = []
let messageContainer = document.querySelector('#messages')
let bitcoinsHash = document.querySelector('#bitcoins')
let transMsg = document.querySelector('#transactions_msg')
let channel

let socket = new Socket("/socket", {params: {token: window.userToken}})
socket.connect()
channel = socket.channel("room:lobby", {})

//join the new client
channel.join()
.receive("ok", resp => { console.log("Joined successfully", resp) })
.receive("error", resp => { console.log("Unable to join", resp) })

   document.getElementById('create_coins').onclick = function () {
     // let messageItem1 = document.createElement("ul");
     // messageItem1.innerText = `Mining bitcoins........`
     // transMsg.appendChild(messageItem1)
     var elem = document.getElementById("myBar");
  var width = 0;
  var id = setInterval(frame, 180);
  function frame() {
    if (width >= 100) {
      clearInterval(id);
    } else {
      width++;
      elem.style.width = width + '%';
      elem.innerHTML = "Mining bitcoins";
    }
  }
     console.log("in coin");
     channel.push("create_coins", {})
     .receive("ok", resp => {
       console.log("after coins created", resp)
     });
    }

  channel.on("start_transactions", payload => {
    let messageItem = document.createElement("ul");
    messageItem.innerText = `Scroll down for Updated Bitcoin Distribution`
    transMsg.removeChild(transMsg.firstChild);
    transMsg.appendChild(messageItem)
    console.log("in start trans");
      console.log(payload.updatedWallet)
      console.log("colors array");
      console.log(payload.colorArr);
      var len = Object.keys(payload.updatedWallet).length;
      var valArr = []
      // var colorArr = []
      var labelArr = []
      for (var i = 0; i < len; i++) {
        valArr.push(payload.updatedWallet[i][0]);
        labelArr.push(payload.updatedWallet[i][1].slice(0, 6));
      }

      new Chart(document.getElementById("bar-chart1"), {
          type: 'bar',
          data: {
            labels: labelArr,
            datasets: [
              {
                label: "BTC Updated",
                backgroundColor: payload.colorArr,
                data: valArr
              }
            ]
          },
          options: {
            legend: { display: false },
            title: {
              display: true,
              fontSize: 16,
              text: 'Bitcoins Distribution (BTC) after Transactions'
            },
            scales: {
              yAxes: [{
                scaleLabel: {
                  display: true,
                  labelString: 'Bitcoin Balance'
                }
              }],
              xAxes: [{
                scaleLabel: {
                  display: true,
                  labelString: 'User Public Key'
                }
              }]
            }
          }
      });
    });

  channel.on("create_coins", payload => {
      console.log("payload.coins_created")
      console.log(payload.coins_created)
      console.log("payload.bitcoins");
      console.log(payload.bitcoins);
      var len = Object.keys(payload.initalWallet).length;
      var tempCoins = payload.initalWallet[len-1][0] - payload.initalWallet[len-2][0];
      var temp = payload.initalWallet[len-2][0];
      var distCoins = Math.ceil(tempCoins / len) ;
      var toAdd = 0
      if(distCoins <= 1){
        toAdd = 1;
      } else if (distCoins > 1){
        toAdd = 2;
      }
      var i = 0;
      for(i;i<len;i++){
        if(tempCoins>0){
          payload.initalWallet[i][0] = payload.initalWallet[i][0] + 1
          tempCoins = tempCoins - 1;
        }
      }
      payload.initalWallet[len-1][0] = temp + tempCoins
      console.log("payload.initalWallet");
      console.log(payload.initalWallet);
      let messageItem = document.createElement("ul");
      messageItem.innerText = `Total coins created: ${payload.coins_created*2}` + `\n` + ` Bitcoins Generated:`
      messageContainer.appendChild(messageItem)

      let messageItem2 = document.createElement("ul");
      messageItem2.innerText = `<- Click to begin Transactions`
      // transMsg.removeChild(transMsg.firstChild);
      transMsg.appendChild(messageItem2)

      var valArr = []
      var colorArr = []
      var labelArr = []
      for (var i = 0; i < len; i++) {
        valArr.push(payload.initalWallet[i][0]);
        colorArr.push(getRandomColor());
        labelArr.push(payload.initalWallet[i][1].slice(0, 6));
      }

      document.getElementById('start_transactions').onclick = function () {
        let messageItem3 = document.createElement("ul");
        messageItem3.innerText = ``
        transMsg.removeChild(transMsg.firstChild);
        transMsg.appendChild(messageItem3)
        console.log("in transaction");
        console.log(payload.coins_created);
        var elem = document.getElementById("myBar");
     var width = 0;
     var id = setInterval(frame, 115);
     function frame() {
       if (width >= 100) {
         clearInterval(id);
       } else {
         width++;
         elem.style.width = width + '%';
         elem.innerHTML = "Performing Transactions";
       }
     }
        channel.push("start_transactions", {coins_created: payload.coins_created ,initial_wallet :payload.initalWallet, colorArr: colorArr})
       }
      let messageItem1 = document.createElement("ul");




      new Chart(document.getElementById("bar-chart"), {
          type: 'bar',
          data: {
            labels: labelArr,
            datasets: [
              {
                label: "BTC",
                backgroundColor: colorArr,
                data: valArr
              }
            ]
          },
          options: {
            legend: { display: false },
            title: {
              display: true,
              fontSize: 16,
              text: 'Bitcoins Distribution (BTC)'
            },
            scales: {
              yAxes: [{
                scaleLabel: {
                  display: true,
                  labelString: 'Bitcoin Balance'
                }
              }],
              xAxes: [{
                scaleLabel: {
                  display: true,
                  labelString: 'User Public Key'
                }
              }]
            }
          }
      });


      var len = Object.keys(payload.bitcoins).length;
      var str = "";
      var i = 0;
      for (i; i<len ; i++){
        str = str + payload.bitcoins[i] + "\n" + "\n";
      }
      messageItem1.innerText = `${str}`
      // bitcoinsHash.removeChild(bitcoinsHash.firstChild);
      bitcoinsHash.appendChild(messageItem1)

    })

    function getRandomColor() {
      var letters = '0123456789ABCDEF';
      var color = '#';
      for (var i = 0; i < 6; i++) {
        color += letters[Math.floor(Math.random() * 16)];
      }
      return color;
    }


export default socketsList
