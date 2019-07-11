import QtQuick 2.2
import Painter 1.0

PainterPlugin {
  Component.onCompleted: {
    alg.ui.addDockWidget("console.qml");
  }
}
