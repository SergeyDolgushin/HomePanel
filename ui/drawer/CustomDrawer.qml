import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts


Drawer {
    id: drawer
    width: 0.33 * root.width
    height: root.height
    edge: Qt.RightEdge

   default property alias contentData: contentColumn.children
    // Добавляем отступы для всего содержимого
   property int contentMargin: 10

    Flickable {
      id: flickableContainer
      anchors {
         fill: parent
         margins: contentMargin
     }
      contentWidth: contentColumn.width
      contentHeight: contentColumn.height

      // clip: true

      ColumnLayout {
        id: contentColumn
        width: drawer.width
        spacing: 5


         // Сюда будет загружено внешнее содержимое
      }
    }

    // // Добавляем рамку для отладки (можно убрать)
    // Rectangle {
    //     anchors.fill: parent
    //     color: "transparent"
    //     border.color: "red"
    //     border.width: 5
    //     visible: true  // Отключено, включите для отладки
    // }

}
