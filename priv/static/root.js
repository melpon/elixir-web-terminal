var term;
var socket = new WebSocket('ws://localhost:8080/websocket');

function WebTerminal(argv) {
    this.argv = argv;
    this.io = null;
}

WebTerminal.prototype.run = function() {
    this.io = this.argv.io.push();

    this.io.onVTKeystroke = this.sendString.bind(this);
    this.io.sendString = this.sendString.bind(this);
    this.io.onTerminalResize = this.onTerminalResize.bind(this);
};

WebTerminal.prototype.sendString = function(str) {
  socket.send(JSON.stringify({
    type: 'input',
    data: str,
  }));
};

WebTerminal.prototype.onTerminalResize = function(col, row) {
  socket.send(JSON.stringify({
    type: 'resize',
    col: col,
    row: row,
  }));
};

socket.addEventListener('open', function() {
  hterm.defaultStorage = new lib.Storage.Local();
  term = new hterm.Terminal();
  window.term = term;
  term.decorate(document.getElementById('terminal'));

  term.setCursorPosition(0, 0);
  term.setCursorVisible(true);
  term.prefs_.set('ctrl-c-copy', true);
  term.prefs_.set('ctrl-v-paste', true);
  term.prefs_.set('use-default-window-copy', true);

  term.runCommandClass(WebTerminal, document.location.hash.substr(1));
  socket.send(JSON.stringify({
    type: 'resize',
    col: term.screenSize.width,
    row: term.screenSize.height,
  }));
});

socket.addEventListener('message', function (event) {
  var js = JSON.parse(event.data);
  if (js.type == 'output') {
    term.io.writeUTF8(js.data);
  }
});
