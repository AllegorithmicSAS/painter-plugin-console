import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.2
import AlgWidgets 2.0
import AlgWidgets.Style 2.0
import "AlgSuggestions" 1.0

Rectangle {
  id: root
  objectName: "QML Console"
  color: AlgStyle.background.color.mainWindow
  height: 200
  property string fontFamilyCode: "Consolas"
  property real layoutStretch: 0.3

  QtObject {
    id: internal_

    property var history: []
    property int historyIndex: -1
  }

  Component.onCompleted: {
    Suggestions.loadPackage(alg, "alg")
  }

  ColumnLayout {
    anchors.fill: root
    spacing: 0

    ListModel {
      id: outputModel
    }

    AlgScrollView {
      id: outputScrollView
      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.bottomMargin: 1
      clip: true

      ListView {
        id: listView
        spacing: 4
        implicitWidth: outputScrollView.viewportWidth
        implicitHeight: contentHeight
        model: outputModel

        delegate: ColumnLayout {
          width: root.width

          GridLayout {
            columns: 2

            Layout.topMargin: 2
            Layout.leftMargin: 4
            Layout.rightMargin: outputScrollView.rightMargin + 4
            Layout.fillWidth: true

            Rectangle {
              Layout.column: 0
              Layout.row: 0
              Layout.columnSpan: 2
              Layout.fillWidth: true
              Layout.fillHeight: true

              color: AlgStyle.colors.gray(10)
              radius: 2
            }

            AlgLabel {
              Layout.alignment: Qt.AlignTop
              Layout.column: 0
              Layout.row: 0
              Layout.margins: 4
              Layout.rightMargin: 0
              text: ">"
              font.family: root.fontFamilyCode
            }

            AlgTextEdit {
              Layout.fillWidth: true
              Layout.column: 1
              Layout.row: 0
              Layout.margins: 4
              Layout.leftMargin: 0
              text: command
              textFormat: Text.PlainText
              wrapMode: TextEdit.Wrap
              backgroundColor: AlgStyle.colors.gray(10)
              readOnly: true
              selectByMouse: true
              font.family: root.fontFamilyCode
              borderActivated: false
            }

            AlgTextEdit {
              Layout.fillWidth: true
              Layout.column: 1
              Layout.row: 1
              text: output
              wrapMode: TextEdit.Wrap
              readOnly: true
              selectByMouse: true
              backgroundColor: AlgStyle.background.color.mainWindow
              font.family: root.fontFamilyCode
              borderActivated: false
              textFormat: outputFormat
            }

            AlgLabel {
              Layout.alignment: Qt.AlignRight
              Layout.column: 1
              Layout.row: 2

              text: qsTr('Time: %1ms').arg(model.elapsedMs)
              font.family: root.fontFamilyCode
            }
          }

          Rectangle {
            Layout.fillWidth: true
            height: 1
            color: AlgStyle.colors.gray(10)
          }
        }
      }
    }

    // Resize handling
    Rectangle {
      Layout.fillWidth: true
      height: 3
      color: AlgStyle.colors.gray(10)

      MouseArea {
        anchors.fill: parent
        anchors.topMargin: -6
        cursorShape: Qt.SplitVCursor

        onPositionChanged: {
          var minStretch = 0.1;
          var rootRelativeY = parent.mapToItem(root, mouse.x, mouse.y).y;
          root.layoutStretch = Math.max(Math.min(1 - rootRelativeY / root.height, 1 - minStretch), minStretch);
        }
      }
    }

    // Suggestions Flow
    SuggestionsFlow {
      id: suggestions_flow
      Layout.fillWidth: true
    }

    // Textedit scrolling implementation based on https://doc.qt.io/qt-5/qml-qtquick-textedit.html#details
    AlgScrollView {
      id: inputScrollView
      Layout.topMargin: 0
      Layout.fillWidth: true
      Layout.maximumHeight: Math.max(20, root.height * root.layoutStretch)
      Layout.minimumHeight: Layout.maximumHeight

      contentWidth: Math.max(width, edit.paintedWidth)
      contentHeight: Math.max(height, edit.paintedHeight)

      function ensureVisible(cursor) {
        if (contentX >= cursor.x) {
          contentX = cursor.x;
        }
        else if(contentX + viewportWidth <= cursor.x + cursor.width) {
          contentX = cursor.x + cursor.width - viewportWidth;
        }
        if (contentY >= cursor.y) {
          contentY = cursor.y;
        }
        else if(contentY + viewportHeight <= cursor.y + cursor.height) {
          contentY = cursor.y + cursor.height - viewportHeight;
        }
      }

      ColumnLayout {
        width: inputScrollView.viewportWidth

        SuggestionsTextEdit {
          id: edit
          Layout.minimumHeight: inputScrollView.viewportHeight
          Layout.minimumWidth: inputScrollView.viewportWidth
          font.family: root.fontFamilyCode
          suggestionsFlow: suggestions_flow

          onCursorRectangleChanged: inputScrollView.ensureVisible(cursorRectangle)

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.IBeamCursor
            acceptedButtons: Qt.NoButton
          }

          Text {
            id: placeholder
            anchors.fill: edit
            anchors.margins: 4
            font.family: root.fontFamilyCode
            text: qsTr("Write script...")
            color: AlgStyle.text.color.disabled
            visible: !edit.text
          }

          function requestEval(evalString) { return eval(evalString) }

          function execJavascript(command) {
            var object = {
              command: command,
              output: "",
              outputFormat: TextEdit.PlainText,
              elapsedMs: 0
            };

            var startTime = new Date().getTime();
            try {
              var result = eval(command)
              object.ellapsedMs = new Date().getTime() - startTime;
              parseText()
              if (result) object.output = JSON.stringify(result, null, '  ');
            }
            catch(exception) {
              object.output =
                '<font color="#cc2a2a">
                  Exception <b>%1</b> at line %2:<br/>
                  %3
                </font>'
                .arg(exception.name)
                .arg(exception.lineNumber)
                .arg(exception.message);
              object.outputFormat = TextEdit.RichText;
            }
            outputModel.append(object);
            listView.forceLayout();
            outputScrollView.contentY = outputScrollView.contentHeight - outputScrollView.viewportHeight;
          }

          function parseCommand(command) {
            var lowerCaseCommand = command.toLowerCase();
            switch(lowerCaseCommand) {
              case "clear":
                outputModel.clear();
                break;
              default:
                execJavascript(command);
                break;
            }
          }

          onReturnPressed: {
            var command = text.trim();
            event.accepted = command.length > 0 && !(event.modifiers & Qt.ShiftModifier);
            if (!event.accepted) {
              return;
            }

            parseCommand(command);

            internal_.history.splice(0, 0, command);
            internal_.historyIndex = -1;
            text = "";
          }

          function setScriptContent(content) {
            text = content
            cursorPosition = text.length
          }

          Keys.onPressed: {
            switch(event.key) {
              case Qt.Key_Up: // Older command
                if (internal_.historyIndex < internal_.history.length - 1) {
                  setScriptContent(internal_.history[++internal_.historyIndex]);
                }
                break;
              case Qt.Key_Down:
                if (internal_.historyIndex > 0) { // More recent command
                  setScriptContent(internal_.history[--internal_.historyIndex]);
                }
                else { // New command
                  internal_.historyIndex = -1;
                  setScriptContent("");
                }
                break;
            }
          }
        }
      }
    }
  }
}
