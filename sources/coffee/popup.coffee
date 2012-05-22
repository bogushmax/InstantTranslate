getParameterByName = (name) ->
  name    = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
  regexS  = "[\\?&]" + name + "=([^&#]*)";
  regex   = new RegExp(regexS);
  results = regex.exec(window.location.search);
  if results == null then new String() else decodeURIComponent(results[1].replace(/\+/g, " "));

($ document).ready ->
  ($ '#popup-cross').on 'click', ->
    parent.postMessage {action: 'hide'}, '*'
    
  word = getParameterByName 'word'
  $("#popup-content h1").text(word)
  # Translate word
  $.get 'http:/translate.google.ru/translate_a/t', 
            { client: 't', text: word, hl: 'ru', sl: 'en'}, 
            (data) ->
              # Decode response from translate.google.ru
              data = eval('(' + data + ')');
              unless data[1]?
                data = data[0]
                ($ '#popup-translate').html '<p>' + data[0][0] + '</p>'
              else
                data = data[1]
                for partOfSpeech in data
                  if partOfSpeech[0] != ''
                    words = new String()
                    for wordNumber in [0...partOfSpeech[1].length - 1]
                      words += partOfSpeech[1][wordNumber] + ', '
                    words += partOfSpeech[1][wordNumber] + '.'
                    ($ '#popup-translate').append '<p><b>' + partOfSpeech[0] + '</b> - <span>' + words + '</span></p>'
              # Send height and width to content_script
              parent.postMessage {action: 'setSize', height: ($ '#popup').height() + 45, width: ($ '#popup').width() + 35}, '*'