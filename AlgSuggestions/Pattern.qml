import QtQuick 2.7
import AlgWidgets 1.0

QtObject {
  // Return internal type of an object
  function objectType(object) {
    if (typeof object === "object" && AlgHelpers.object.isArray(object)) return "array";
    return typeof object;
  }

  // generate a pattern based on the name and internal type of an object
  function generatePattern(name, type) {
    var pattern = {};
    var suffix = type === "object" ? "." : type === "function" ? "(" : "";
    var postString = type === "function" ? ")" : "";
    pattern.root = name + suffix;
    pattern.postString = postString;
    pattern.children = [];
    return pattern;
  }

  // introspect an object and generate the correct pattern for it
  // recursive function, when calling it the parent must be the pattern of the root object
  // see generatePattern
  function generateObjectPattern(object, parent) {
    if (typeof object === "object") {
      for (var key in object) {
        var value = object[key];
        var keyPattern = generatePattern(key, objectType(value))
        parent.children.push(keyPattern)
        generateObjectPattern(value, keyPattern)
      }
    }
  }

  // Generate full pattern of an object
  // Return the pattern
  function generateFullPattern(object, name) {
    var pattern = generatePattern(name, objectType(object));
    generateObjectPattern(object, pattern);
    return pattern;
  }

  /////////////////////
  // SUGGEST PATTERN //
  /////////////////////
  // Generate a suggestion pattern
  function generateSuggest(value, postString, contSuggests) {
    var suggest = {}
    suggest.value = value ? value : ""
    suggest.postString = postString ? postString : ""
    suggest.contSuggests = !!contSuggests
    return suggest
  }

  // Generate a suggestion pattern from a model pattern
  function generateSuggestFromPattern(pattern) {
    return generateSuggest(pattern.root, pattern.postString, pattern.children && pattern.children.length > 0)
  }
}
