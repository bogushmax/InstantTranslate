# Extension's state on current page
state = {}

state.resetSelectedWord = ->
  if state.selectedWord?
    ($ state.selectedWord).removeClass 'word-highlighted'
    state.selectedWord = null

state.getSelectedWord = -> ($ state.selectedWord).text()

state.hideAll = (event) -> state.resetSelectedWord(); popup.hide()

state.enable = ->
  ($ 'body').addClass 'instant-translate-active'
  ($ '.word').on 'click', (event) ->
    event.stopPropagation()
    unless state.selectedWord == this
      ($ state.selectedWord).removeClass 'word-highlighted'
      # Save span element into state variable
      state.selectedWord = this
      ($ state.selectedWord).addClass 'word-highlighted'
      popup.translate state.getSelectedWord()
  ($ document).on 'click', state.hideAll
  ($ window).on 'resize', state.hideAll
  ($ window).on 'scroll', state.hideAll
state.disable = ->
  ($ 'body').removeClass 'instant-translate-active'
  state.hideAll()
  ($ '.word').off 'click'
  ($ document).off 'click'
  ($ window).off 'resize'
  ($ window).off 'scroll'

popup = {}

popup.inject = ->
  popup.frame = ($ """
                      <iframe id="popup"
                        style="position: relative; visibility: hidden;"
                        frameborder="no"
                        scrolling="no" noresize>
                      </iframe>
                   """)
  ($ window).on 'message', (event) ->
    data = event.originalEvent.data
    switch data.action
      when 'setSize'
        popup.frame.height data.height
        popup.frame.width  data.width
        popup.setPosition()
      when 'hide'
        popup.hide()
        state.resetSelectedWord()
  ($ 'body').append popup.frame

popup.hide = -> popup.frame.css {visibility: 'hidden'}
popup.show = -> popup.frame.css {visibility: 'visible'}

popup.translate = (word) ->
  popup.hide()
  popup.frame.attr 'src', chrome.extension.getURL('views/popup.html') + '?word=' + word

# Event: set up popup position
# TODO:  Drop 'jquery select' selected word
popup.setPosition = ->
  word = ($ state.selectedWord)
  offsetLeft = (Math.floor(word.width() / 2) + word.offset().left) - popup.frame.width() + 110
  offsetTop  = word.offset().top - popup.frame.height() + 10
  popup.frame.offset {left: offsetLeft, top: offsetTop}
  popup.show()

# Ignore list of text nodes's parents
TAGS_IGNORE_LIST = ['A', 'BUTTON', 'TEXTAREA', 'FIELDSET', 'LABEL', 'FORM', 'SCRIPT']

# TODO: Drop jQuery from initialize
# Declare initialize procedure (wrap words)
initialize = ->
  # Filter for TreeWalker, sets text nodes
  filter = (node) ->
    if node.nodeType == Node.TEXT_NODE
      return NodeFilter.FILTER_ACCEPT
    else
      if node.tagName in TAGS_IGNORE_LIST or node.onclick != null
        return NodeFilter.FILTER_REJECT
      else
        return NodeFilter.FILTER_SKIP
  # TreeWalker with custom filter
  walker = document.createTreeWalker document.body,
                                     NodeFilter.SHOW_ELEMENT + NodeFilter.SHOW_TEXT,
                                     filter,
                                     false
  isAlpha = (char) ->
    (char >= 'a' and char <= 'z') or
    (char >= 'A' and char <= 'Z')
  # Create text node
  createTextElement = (text) ->
    document.createTextNode text
  # Create span word element
  createWordElement = (word) ->
    span = document.createElement 'span'
    span.classList.add 'word'
    span.appendChild document.createTextNode word
    span
  # Iterate nodes
  while walker.nextNode()
    # Remove last handled node
    lastNode.remove() if lastNode?
    node = ($ walker.currentNode)
    text = node.text()
    # Self-invoking function (Isolate scope)
    do ->
      # Coffeescript hack for iterating characters
      for char, index in text.split ''
        # Finate machine with two states, isWordState (true, false)
        if isAlpha char
          unless isWordState and isWordState?
            isWordState = true
            node.before createTextElement token if token?
            token = new String()
        else
          if isWordState or not isWordState?
            isWordState = false
            node.before createWordElement token if token?
            token = new String()
        token += char
        if index == text.length - 1
          if isWordState
            node.before createWordElement token
          else
            node.before createTextElement token
    # Save current node for removing in next iteration
    lastNode = node
  # Inject popup into current page's body
  popup.inject()

# Handle messages from background
onMessage = (message) ->
  if message.isEnabled then state.enable() else state.disable()

# Wait message from background script with state
chrome.extension.onRequest.addListener onMessage

# Call initialize procedure
initialize()

# Send initialize message to extension script
chrome.extension.sendRequest {isInitialized: true}, onMessage
