// Generated by CoffeeScript 1.3.1
(function() {
  var getParameterByName;

  getParameterByName = function(name) {
    var regex, regexS, results;
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    regexS = "[\\?&]" + name + "=([^&#]*)";
    regex = new RegExp(regexS);
    results = regex.exec(window.location.search);
    if (results === null) {
      return new String();
    } else {
      return decodeURIComponent(results[1].replace(/\+/g, " "));
    }
  };

  ($(document)).ready(function() {
    var word;
    ($('#popup-cross')).on('click', function() {
      return parent.postMessage({
        action: 'hide'
      }, '*');
    });
    word = getParameterByName('word');
    $("#popup-content h1").text(word);
    return $.get('http:/translate.google.ru/translate_a/t', {
      client: 't',
      text: word,
      hl: 'ru',
      sl: 'en'
    }, function(data) {
      var partOfSpeech, wordNumber, words, _i, _j, _len, _ref;
      data = eval('(' + data + ')');
      if (data[1] == null) {
        data = data[0];
        ($('#popup-translate')).html('<p>' + data[0][0] + '</p>');
      } else {
        data = data[1];
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          partOfSpeech = data[_i];
          if (partOfSpeech[0] !== '') {
            words = new String();
            for (wordNumber = _j = 0, _ref = partOfSpeech[1].length - 1; 0 <= _ref ? _j < _ref : _j > _ref; wordNumber = 0 <= _ref ? ++_j : --_j) {
              words += partOfSpeech[1][wordNumber] + ', ';
            }
            words += partOfSpeech[1][wordNumber] + '.';
            ($('#popup-translate')).append('<p><b>' + partOfSpeech[0] + '</b> - <span>' + words + '</span></p>');
          }
        }
      }
      return parent.postMessage({
        action: 'setSize',
        height: ($('#popup')).height() + 45,
        width: ($('#popup')).width() + 35
      }, '*');
    });
  });

}).call(this);