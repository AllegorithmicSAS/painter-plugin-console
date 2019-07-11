import QtQuick 2.7
import "autocompletemodel.js" as AutoComplete

QtObject {
  // internal, do not try to use them
  // Default containers of the model
  readonly property var __fromJSModels: AutoComplete.model
  property var __fromPackages: []
  property var __fromVariables: []
  // Pattern of the model
  readonly property QtObject __pattern: Pattern {}

  // push a new package pattern
  // doesn't care about duplicates
  function pushPackage(package_, packageName) {
    __fromPackages.push(__pattern.generateFullPattern(package_, packageName))
  }

  // push a new variable pattern
  // doesn't care about duplicates
  function pushVariable(pattern) {
    __fromVariables.push(pattern)
  }

  // clear all packages
  function clearPackages() {
    __fromPackages = []
  }

  // clear all variables
  function clearVariables() {
    __fromVariables = []
  }

  // generate variables list with the object list
  // object list must respect the pattern:
  // [{
  //   variant: {...},
  //   name: "..."
  //  },...
  // ]
  // You can also pass a list of string
  function generateVariables(objectList) {
    clearVariables();
    // generate package from variables
    for (var i = 0; i < objectList.length; ++i) {
      if (typeof objectList[i] === "object") {
        pushVariable(__pattern.generateFullPattern(objectList[i].variant, objectList[i].name));
      }
      else {
        // no custom introspection
        pushVariable(__pattern.generatePattern(objectList[i], "variable"))
      }
    }
  }

  // return full model
  function model() {
    var returnList = __fromJSModels.concat(__fromPackages, __fromVariables);
    return returnList;
  }

  // search a key in a list of pattern
  function findInList(searchList, key) {
    var futureList = null
    searchList.forEach(function(keywordObject) {
      if (keywordObject.root === key) {
        futureList = keywordObject.children
      }
    })
    return futureList
  }

  // search and return completion in actual model
  // force_listing allows to return an array if more than one element are found
  // else, a prefix is returned if more than one element are found
  function searchIn(parsedWord, force_listing) {
    var searchList = model()

    var key = parsedWord.pop()
    var length = parsedWord.length;
    var tab = [];

    var currentList = searchList;
    var currentIndex = 0;
    while (currentList && currentIndex < length) {
      currentList = findInList(currentList, parsedWord[currentIndex] + ".")
      ++currentIndex
    }

    if (currentList) {
      currentList.forEach(function(keywordPattern) {
        if (keywordPattern.root.toLowerCase().indexOf(key.toLowerCase()) === 0) {
          tab.push(__pattern.generateSuggestFromPattern(keywordPattern))
        }
      })
    }

    if (tab.length === 0) return tab
    if (tab.length === 1) {
      return tab[0]
    }
    else {
      var prefix = findPrefix(tab)
      if (!force_listing && prefix.value.length > key.length) {
        return prefix
      }
      return tab
    }
  }

  // try to find the actual prefix in the list
  // (common first characters in the list)
  function findPrefix(keyList) {
    var lastKey = keyList[0].value
    var index = 0;
    var prefixFound = false
    while (!prefixFound && index < lastKey.length) {
      var match = true
      var listIndex = 1
      while (match && listIndex < keyList.length) {
        match = keyList[listIndex].value.charAt(index) === lastKey.charAt(index)
        ++listIndex
      }
      prefixFound = !match
      ++index;
    }
    return __pattern.generateSuggest(lastKey.slice(0, index - 1), "", true)
  }
}
