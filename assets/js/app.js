// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"


import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"



document.addEventListener('DOMContentLoaded', function() {

  function process(e, x) {
    if (e.key == "Enter") {
      x.value = "";
    }
  }

  window.process = process

  let Hooks = {}

  Hooks.MyTextArea = {
    updated(){
      console.log(this.el.value);
      console.log(this.el.dataset.pendingVal);
      this.el.value = this.el.dataset.pendingVal
    }
  }

  let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
  let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

  liveSocket.connect()

  window.liveSocket = liveSocket
}, false);



// Connect if there are any LiveViews on the page

// Expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
// The latency simulator is enabled for the duration of the browser session.
// Call disableLatencySim() to disable:
// >> liveSocket.disableLatencySim()

