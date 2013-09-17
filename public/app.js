$(document).ready(function() {
  var es = new EventSource('/connect');

  es.onmessage = function(e) {
    var msg = $.parseJSON(e.data);
    var str = "<li class='" + msg.type + "'><strong>" + msg.msg + "</strong> at " + msg.at + "</li>"

    $('#container').prepend(str);
  }
});
