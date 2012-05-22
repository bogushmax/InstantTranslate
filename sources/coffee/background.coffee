state = {}
badge = {}

# Extension's state(enabled, disabled) methods
state.initialize = ->
  localStorage['isEnabled'] or= 't'

state.isEnabled = ->
  if localStorage['isEnabled'] == 't' then true else false

state.enable = ->
  localStorage['isEnabled'] = 't'
  return true

state.disable = ->
  localStorage['isEnabled'] = 'f'
  return false

# Toggle state
state.invert = ->
  if state.isEnabled() then state.disable() else state.enable()

state.send = (tabId) ->
  chrome.tabs.sendRequest tabId, {isEnabled: state.isEnabled()}

# Extension's badge(on, off) methods
badge.set = (text, color) ->
  chrome.browserAction.setBadgeText text: text
  chrome.browserAction.setBadgeBackgroundColor color: color

badge.setOn = ->
  badge.set 'ON', [255, 0, 0, 255]

badge.setOff = ->
  badge.set 'OFF', [150, 150, 150, 255]

state.initialize()
# Initialize badge
if state.isEnabled() then badge.setOn() else badge.setOff()
chrome.browserAction.onClicked.addListener (tab) ->
  # Toggle 'off' and 'on' badges
  if state.invert() then badge.setOn() else badge.setOff()
  state.send tab.id

# Wait initialize message from content script
chrome.extension.onRequest.addListener (request, sender, sendResponse) ->
  if request.isInitialized
    sendResponse {isEnabled: state.isEnabled()}
    console.log sender

# Send state to selected tab's content script
chrome.tabs.onActiveChanged.addListener (tabId, selectInfo) ->
  state.send tabId
