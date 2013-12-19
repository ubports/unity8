import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    id: root
    property alias mascot: mascotImage.source
    property alias title: titleLabel.text
    property alias subtitle: subtitleLabel.text
    property alias price: priceLabel.text
    property alias oldPrice: oldPriceLabel.text
    property alias altPrice: altPriceLabel.text

    visible: mascotImage.status === Image.Ready || title || price
    height: row.height > 0 ? row.height + row.spacing * 2 : 0

    Row {
        id: row
        objectName: "outerRow"

        anchors { top: parent.top; left: parent.left; right: parent.right; margins: spacing }
        spacing: units.gu(1)

        UbuntuShape {
            id: mascotShape
            objectName: "mascotShape"

            width: units.gu(8)
            height: units.gu(8)
            visible: image.status === Image.Ready

            image: Image {
                id: mascotImage
                sourceSize { width: mascotShape.width; height: mascotShape.height }
            }
        }

        Column {
            objectName: "column"
            width: parent.width - x

            Label {
                id: titleLabel
                anchors { left: parent.left; right: parent.right }
                elide: Text.ElideRight
                objectName: "titleLabel"
                font.weight: Font.DemiBold
                wrapMode: Text.Wrap
                maximumLineCount: 2
            }

            Label {
                id: subtitleLabel
                anchors { left: parent.left; right: parent.right }
                elide: Text.ElideRight
                visible: titleLabel.text && text
            }

            Row {
                id: prices
                objectName: "prices"
                anchors { left: parent.left; right: parent.right }

                property int labels: {
                    var labels = 1; // price always visible
                    if (oldPriceLabel.text !== "") labels += 1;
                    if (altPriceLabel.text !== "") labels += 1;
                    return labels;
                }
                property real labelWidth: width / labels

                Label {
                    id: priceLabel
                    width: parent.labelWidth
                    elide: Text.ElideRight
                    font.weight: Font.DemiBold
                    color: Theme.palette.selected.foreground
                }

                Label {
                    id: oldPriceLabel
                    objectName: "oldPriceLabel"
                    width: parent.labelWidth
                    elide: Text.ElideRight
                    horizontalAlignment: parent.labels === 3 ? Text.AlignHCenter : Text.AlignRight
                }

                Label {
                    id: altPriceLabel
                    width: parent.labelWidth
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }
}
