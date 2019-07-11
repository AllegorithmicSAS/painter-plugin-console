import "."
import QtQuick 2.7
import QtQuick.Layouts 1.3
import AlgWidgets 2.0
import AlgWidgets.Style 2.0

ColumnLayout {
  id: root
  property var suggests: []
  property alias helperText: helper.text
  enabled: false
  visible: suggests.length > 0
  
  function deselectAll() {
    for (var i = 0; i < suggestionItems.count; ++i) {
      suggestionItems.itemAt(i).select(false)
    }
  }

  function selectItem(index) {
    deselectAll()
    if (index < suggestionItems.count && index >= 0) {
      suggestionItems.itemAt(index).select(true)
    }
  }

  function selectedItem() {
    for (var i = 0; i < suggestionItems.count; ++i) {
      if (suggestionItems.itemAt(i).selected) {
        return suggestionItems.itemAt(i)
      }
    }
    return null
  }

  function selectNext() {
    var itemSelected = selectedItem()
    if (itemSelected && itemSelected.itemIndex < suggests.length - 1) {
      selectItem(itemSelected.itemIndex + 1)
    }
    else selectItem(0);
  }

  function selectPrevious() {
    var itemSelected = selectedItem()
    if (itemSelected && itemSelected.itemIndex > 0) {
      selectItem(itemSelected.itemIndex - 1)
    }
    else selectItem(suggests.length - 1);
  }

  AlgLabel {
    id: helper
    leftPadding: 4
    rightPadding: 4
    text: ""
    color: AlgStyle.text.color.normal
    visible: !enabled && text
  }

  Flow {
    id: suggestionsFlow
    Layout.fillWidth: true
    leftPadding: 4
    rightPadding: 4
    spacing: 6

    Repeater {
      id: suggestionItems
      model: root.suggests
      AlgLabel {
        text: modelData.value
        color: enabled ? 
                selected ?
                  AlgStyle.colors.highlight_color :
                  AlgStyle.text.color.normal :
                AlgStyle.text.color.disabled
        property bool selected: false
        property int itemIndex: index
        property var itemData: modelData
        font.bold: selected

        function select(selected_) {
          selected = selected_
        }
      }
    }
  }
}
