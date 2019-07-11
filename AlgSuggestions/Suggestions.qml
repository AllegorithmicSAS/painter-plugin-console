pragma Singleton
import QtQuick 2.7

QtObject {
  // use force_listing to return an array if more than one element are found
  // else, a prefix is returned if more than one element are found
  function searchCompletion(line, force_listing) {
    return __model.searchIn(__separators.lastWordsInLine(line), force_listing)
  }
  // search variables in a valid line of code
  function searchVariable(line) {
    __variables.findVars(line, __separators);
    return __variables.variableList;
  }
  // Update the variable list
  // there is a solution to skip this method:
  // define a js script file and use include function to update the global scope
  function updateVariableList(objectList) {
    if (objectList.length === 0) __model.generateVariables(__variables.variableList)
    else __model.generateVariables(objectList)
  }
  // Generate keywords from a package
  function loadPackage(package_, packageName) {
    __model.pushPackage(package_, packageName)
  }
  // Get the edited word of a line
  function editedWord(line) {
    return __separators.lastWordsInLine(line)
  }

  readonly property QtObject __separators: Separators {}

  readonly property QtObject __variables: Variables {}

  readonly property QtObject __model: Model {}
}
