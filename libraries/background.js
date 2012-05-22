// Generated by CoffeeScript 1.3.1
(function() {
  var badge, state;

  state = {};

  badge = {};

  state.initialize = function() {
    return localStorage['isEnabled'] || (localStorage['isEnabled'] = 't');
  };

  state.isEnabled = function() {
    if (localStorage['isEnabled'] === 't') {
      return true;
    } else {
      return false;
    }
  };

  state.enable = function() {
    localStorage['isEnabled'] = 't';
    return true;
  };

  state.disable = function() {
    localStorage['isEnabled'] = 'f';
    return false;
  };

  state.invert = function() {
    if (state.isEnabled()) {
      return state.disable();
    } else {
      return state.enable();
    }
  };

  state.send = function(tabId) {
    return chrome.tabs.sendRequest(tabId, {
      isEnabled: state.isEnabled()
    });
  };

  badge.set = function(text, color) {
    chrome.browserAction.setBadgeText({
      text: text
    });
    return chrome.browserAction.setBadgeBackgroundColor({
      color: color
    });
  };

  badge.setOn = function() {
    return badge.set('ON', [255, 0, 0, 255]);
  };

  badge.setOff = function() {
    return badge.set('OFF', [150, 150, 150, 255]);
  };

  state.initialize();

  if (state.isEnabled()) {
    badge.setOn();
  } else {
    badge.setOff();
  }

  chrome.browserAction.onClicked.addListener(function(tab) {
    if (state.invert()) {
      badge.setOn();
    } else {
      badge.setOff();
    }
    return state.send(tab.id);
  });

  chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
    if (request.isInitialized) {
      sendResponse({
        isEnabled: state.isEnabled()
      });
      return console.log(sender);
    }
  });

  chrome.tabs.onActiveChanged.addListener(function(tabId, selectInfo) {
    return state.send(tabId);
  });

}).call(this);
