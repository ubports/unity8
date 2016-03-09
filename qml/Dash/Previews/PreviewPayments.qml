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

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Payments 0.1

/*! \brief Preview widget for a purchase button.
 *
 *  When clicked, this button starts the payments service.
 *  Then it waits until the purchase finishes or fails.
 *  Those events trigger the corresponding actions.
 */

PreviewWidget {
    id: root

    implicitHeight: paymentButton.implicitHeight
    implicitWidth: paymentButton.implicitWidth

    Button {
        id: paymentButton
        objectName: "paymentButton"

        color: UbuntuColors.orange
        text: paymentClient.formattedPrice
        onClicked: {
            paymentClient.start();
            paymentButton.opacity = 0;
        }
        anchors.right: parent.right
        width: (root.width - units.gu(1)) / 2
        opacity: 1
        visible: paymentButton.opacity == 0 ? false : true
        Behavior on opacity { PropertyAnimation { duration: UbuntuAnimation.FastDuration } }

        Payments {
            id: paymentClient
            objectName: "paymentClient"

            property var source: widgetData["source"]

            price: source["price"]
            currency: source["currency"]
            storeItemId: source["store_item_id"]
            onPurchaseCompleted: {
                root.triggered(widgetId, "purchaseCompleted", source);
            }
            onPurchaseError: {
                paymentButton.opacity = 1;
                root.triggered(widgetId, "purchaseError", source);
            }
            onPurchaseCancelled: {
                paymentButton.opacity = 1;
                root.triggered(widgetId, "purchaseCancelled", source);
            }
        }
    }

    ProgressBar {
        id: loadingBar
        objectName: "loadingBar"
        indeterminate: true
        anchors.fill: paymentButton
        opacity: 1 - paymentButton.opacity
        visible: !paymentButton.visible
    }
}
