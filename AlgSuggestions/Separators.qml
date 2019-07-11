import QtQuick 2.7

QtObject {
  // default regexp
  readonly property var groupsSeparators: /[\s,;!\-+*\/=<>^%:\?(){}\[\]&|"'~]+/
  readonly property var wordsSeparators: "."

  // Functions to parse lines

  // parse all groups in a line
  // separators (optional) is the regexp associated to the parsing
  // see groupsSeparators for the default regexp
  function groups(line, separators) {
    if (!separators) separators = groupsSeparators;
    return line.split(separators);
  }

  // return the last parsed group found in a line
  // separators (optional) is the regexp associated to the parsing
  // see groupsSeparators for the default regexp
  function lastGroup(line, separators) {
    return groups(line, separators).pop();
  }

  // parse a group into words
  // separators (optional) is the regexp associated to the parsing
  // see wordsSeparators for the default regexp
  function words(group, separators) {
    if (!separators) separators = wordsSeparators;
    return group.split(separators);
  }

  // return the last parsed word found in a group
  // separators (optional) is the regexp associated to the parsing
  // see wordsSeparators for the default regexp
  function lastWord(group, separators) {
    return words(group, separators).pop();
  }

  // return the last group words found in a line
  // group_separators (optional) is the regexp associated to the parsing
  // see groupsSeparators for the default regexp
  // word_separators (optional) is the regexp associated to the parsing
  // see wordsSeparators for the default regexp
  function lastWordsInLine(line, group_separators, word_separators) {
    return words(lastGroup(line, group_separators), word_separators);
  }

  // return the last parsed word found in a line
  // group_separators (optional) is the regexp associated to the parsing
  // see groupsSeparators for the default regexp
  // word_separators (optional) is the regexp associated to the parsing
  // see wordsSeparators for the default regexp
  function lastWordInLine(line, group_separators, word_separators) {
    return lastWord(lastGroup(line, group_separators), word_separators);
  }
}
