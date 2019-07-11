import QtQuick 2.7
import AlgWidgets 1.0

QtObject {
  // default variable declaration keys
  readonly property var declarationKeys: ["var"]
  // default variable list
  readonly property var variableList: __variableList

  // internal, please do not use!!!
  property var __variableList: []

  // Functions to retrieve declared variables in lines
  // lines must be complete and valid!!!
  // Use the Separators template

  // research all variables in a line
  // separators must respect the Separators template (at least groups function)
  // keys (optional) is a list containing all declaration keys for variables
  // see declarationKeys for the default value
  function varNames(line, separators, keys) {
    if (!keys) keys = declarationKeys;
    var splittedLine = separators.groups(line);
    var isVariable = false;
    var resultList = [];
    splittedLine.forEach(function(group) {
      if (isVariable) {
        resultList.push(group);
        isVariable = false;
      }
      else {
        if (AlgHelpers.object.isArray(keys)) isVariable = keys.indexOf(group) !== -1;
        else isVariable = keys !== group;
      }
    });
    return resultList;
  }

  // try to push a variable name in a list of variables
  // duplicates are ignored
  // return true if pushed
  function pushVariable(name, list) {
    var isInList = list.indexOf(name) !== -1;
    if (!isInList) list.push(name)
    return isInList;
  }

  // try to push variable names in a list of variables
  // duplicates are ignored
  // return true if at least one name is pushed
  function pushVariables(names, list) {
    var updated = false;
    names.forEach(function(name) {
      if (pushVariable(name, list)) updated = true;
    });
    return updated;
  }

  // find and push in list
  // separators must respect the Separators template (at least groups function)
  // keys (optional) is a list containing all declaration keys for variables
  // see declarationKeys for the default value
  // list (optional) output list
  // default is the internal list
  // return true if at least one variable is pushed
  function findVars(line, separators, keys, list) {
    if (!list) list = __variableList;
    if (!keys) keys = declarationKeys;
    return pushVariables(varNames(line, separators, keys), list);
  }
}
