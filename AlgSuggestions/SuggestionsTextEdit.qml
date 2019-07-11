import "."
import QtQuick 2.7
import AlgWidgets 2.0
import AlgWidgets.Style 2.0

AlgTextEdit {
  property SuggestionsFlow suggestionsFlow

  onSuggestionsFlowChanged: {
    if (suggestionsFlow) {
      suggestionsFlow.helperText = "Use CTRL+SPACE to start the auto complete navigation"
    }
  }

  signal returnPressed(var event)

  // to be overloaded
  function requestEval(evalString) {
    alg.log.error("requestEval function must be overloaded to correctly parse a command. "
      + "Please add the following line when reimplementing SuggestionsTextEdit: "
      + "function requestEval(evalString) { return eval(evalString) }")
    return ""
  }

  QtObject {
    id: internal

    function assertFlowNotSet() {
      if (!suggestionsFlow) {
        alg.log.error("You must declare a flow in order to enable the auto completion")
        return false
      }
      return true
    }

    function clearSuggestionsFlow() {
      suggestionsFlow.suggests = []
      suggestionsFlow.enabled = false
    }

    function commitCommand(event) {
      // Reinit suggestions and get current selected item
      var selectedItem = suggestionsFlow.selectedItem()

      if (selectedItem) {
        complete(selectedItem.itemData)
      }
      else {
        clearSuggestionsFlow()
        returnPressed(event)
      }
    }
  }

  function parseText() {
    // Push variables in Suggests
    var allVars = Suggestions.searchVariable(text)
    var varNameAndObject = []
    for (var i = 0; i < allVars.length; ++i) {
      var newObj = {}
      newObj.name = allVars[i]
      // Impossible to do this directly in Suggestions
      // the eval function doesn't recognize the value
      // Must be a problem of file context
      newObj.variant = requestEval(allVars[i])
      varNameAndObject.push(newObj)
    }
    Suggestions.updateVariableList(varNameAndObject)
  }

  function getSuggest(force_listing, future_key) {
    if (!internal.assertFlowNotSet()) return
    var text2complete = text.substr(0, cursorPosition)
    var suggestion = Suggestions.searchCompletion(text2complete.concat(future_key ? future_key : ""), force_listing)
    if (!Array.isArray(suggestion)) {
      if (!force_listing) {
        complete(suggestion)
      }
      else {
        var array = []
        array.push(suggestion)
        suggestionsFlow.suggests = array
      }
    }
    else {
      suggestionsFlow.suggests = suggestion
    }
    if (suggestionsFlow.suggests && suggestionsFlow.enabled) suggestionsFlow.selectItem(0)
  }

  function complete(completion) {
    if (!internal.assertFlowNotSet()) return
    var text2complete = text.substr(0, cursorPosition)
    var textEnd = text.substr(cursorPosition)
    // Get the current edited keyword
    // 'alg.log.wa' -> ["alg", "log", "wa"]
    // 'alg.log.' -> ["alg", "log", ""]
    // 'JSON.stringify(alg.log.wa' -> ["alg", "log", "wa"]
    var splittedWord = Suggestions.editedWord(text2complete)
    var lastCharIndex = text2complete.length - 1
    // length of the last component
    var preeditLength = splittedWord.pop().length
    // remove the last component from the original string
    text2complete = text2complete.slice(0, text2complete.length - preeditLength)
    // then, add the new component and the post completion
    text = text2complete.concat(completion.value, completion.postString, textEnd)
    // Move the cursor to the end of the new component, ignoring the post completion
    cursorPosition = text.length - completion.postString.length - textEnd.length
    if (completion.contSuggests) {
      getSuggest()
    }
    else internal.clearSuggestionsFlow()
  }

  Keys.onReturnPressed: internal.commitCommand(event)
  Keys.onEnterPressed: internal.commitCommand(event)

  Keys.onPressed: {
    if (!internal.assertFlowNotSet()) return
    if (event.modifiers === Qt.ControlModifier
      || event.modifiers === Qt.MetaModifier)
    {
      switch(event.key) {
        case Qt.Key_Space:
          suggestionsFlow.enabled = true
          var selectedItem = suggestionsFlow.selectedItem()
          if (!suggestionsFlow.visible || !selectedItem) {
            getSuggest()
          }
          else {
            complete(selectedItem.itemData)
          }
          event.accepted = true
          break;
      }
    }
    else {
      switch(event.key) {
        case Qt.Key_Left:
          if (suggestionsFlow.visible && suggestionsFlow.enabled) {
            suggestionsFlow.selectPrevious()
            event.accepted = true
            return
          }
          break
        case Qt.Key_Right:
          if (suggestionsFlow.visible && suggestionsFlow.enabled) {
            suggestionsFlow.selectNext()
            event.accepted = true
            return
          }
          break
      }

      if (/^([a-z0-9_\.])$/i.test(event.text)) {
        getSuggest(true, event.text)
        return
      }

      // disable all suggestions
      internal.clearSuggestionsFlow()
    }
  }
}
