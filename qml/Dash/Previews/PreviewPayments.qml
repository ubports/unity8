/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.1
import Ubuntu.Components 0.1
import Ubuntu.Payments 0.1

/*! \brief Preview widget for a purchase button.
 *
 *  When clicked, this button starts the payments service.
 *  Then it waits until the purchase finishes or fails.
 *  Those events trigger the corresponding signals.
 */

PreviewWidget {
    id: root

    implicitHeight: paymentButton.implicitHeight
    implicitWidth: paymentButton.implicitWidth

    Button {
        id: paymentButton

        property var source: widgetData["source"]
        objectName: "paymentButton"
        color: Theme.palette.selected.foreground
        text: paymentClient.formattedPrice
        iconSource: data && data.icon || ""
        iconPosition: "left"
        onClicked: paymentClient.start()
        anchors.right: parent.right
        width: (root.width - units.gu(1)) / 2

        Payments {
            id: paymentClient
            price: paymentButton.source["price"]
            currency: paymentButton.source["currency"]
            storeItemId: paymentButton.source["store_item_id"]
            onFinished: root.triggered(widgetId, "finished", data)
            onCanceled: root.triggered(widgetId, "canceled", data)
            onError: root.triggered(widgetId, "error", data)
        }
    }
}
