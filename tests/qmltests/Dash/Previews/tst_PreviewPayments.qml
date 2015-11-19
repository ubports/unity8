/*
 * Copyright 2014 Canonical Ltd.
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
import QtTest 1.0
import "../../../../qml/Dash/Previews"
import Unity.Test 0.1 as UT
import Ubuntu.Components 1.3

Rectangle {
    id: root
    width: units.gu(60)
    height: units.gu(80)

    property var jsonPurchase: {
        "source": { "price" : 0.99, "currency": "USD", "store_item_id": "com.example.package" }
    }

    property var jsonPurchaseError: {
        "source": { "price" : 0.99, "currency": "USD", "store_item_id": "com.example.invalid" }
    }

    property var jsonPurchaseCancel: {
        "source": { "price" : 0.99, "currency": "USD", "store_item_id": "com.example.cancel" }
    }

    SignalSpy {
        id: spy
        target: previewPayments
        signalName: "triggered"
    }

    PreviewPayments {
        id: previewPayments
        widgetId: "previewPayments"
        width: units.gu(30)
    }

    UT.UnityTestCase {
        name: "PreviewPaymentsTest"
        when: windowShown
        property var paymentClient

        function init()
        {
            paymentClient = findInvisibleChild(previewPayments, "paymentClient");
            verify(paymentClient, "Could not find the payment client object.");
        }

        function cleanup()
        {
            paymentClient = null;
            previewPayments.widgetData = null;
            spy.clear();
            var button = findChild(previewPayments, "paymentButton");
            button.opacity = 1;
        }

        function test_purchase_text_display() {
            previewPayments.widgetData = jsonPurchase;

            var button = findChild(previewPayments, "paymentButton");
            verify(button, "Button not found.");
            compare(button.text, "0.99USD");
        }

        function test_purchase_completed() {
            // Exercise the purchaseCompleted signal here.
            previewPayments.widgetData = jsonPurchase;

            var button = findChild(previewPayments, "paymentButton");
            verify(button, "Button not found.");

            mouseClick(button);

            paymentClient.process();
            spy.wait();

            var args = spy.signalArguments[0];
            compare(args[0], "previewPayments");
            compare(args[1], "purchaseCompleted");
            compare(args[2], jsonPurchase["source"]);
        }

        function test_progress_show() {
            // Make sure the progress bar is shown.
            previewPayments.widgetData = jsonPurchase;

            var button = findChild(previewPayments, "paymentButton");
            var progress = findChild(previewPayments, "loadingBar");

            tryCompare(progress, "visible", false);
            tryCompare(progress, "opacity", 0);
            tryCompare(button, "visible", true);
            tryCompare(button, "opacity", 1);

            mouseClick(button);

            paymentClient.process();
            spy.wait();

            tryCompare(progress, "visible", true);
            tryCompare(progress, "opacity", 1);
            tryCompare(button, "visible", false);
            tryCompare(button, "opacity", 0);
        }

        function test_progress_show_cancel() {
            // Make sure the progress bar is shown.
            previewPayments.widgetData = jsonPurchaseError;

            var button = findChild(previewPayments, "paymentButton");
            var progress = findChild(previewPayments, "loadingBar");

            tryCompare(progress, "visible", false);
            tryCompare(progress, "opacity", 0);
            tryCompare(button, "visible", true);
            tryCompare(button, "opacity", 1);

            mouseClick(button);

            tryCompare(progress, "visible", true);
            tryCompare(progress, "opacity", 1);
            tryCompare(button, "visible", false);
            tryCompare(button, "opacity", 0);

            paymentClient.process();
            spy.wait();

            tryCompare(progress, "visible", false);
            tryCompare(progress, "opacity", 0);
            tryCompare(button, "visible", true);
            tryCompare(button, "opacity", 1);
        }

        function test_purchase_error() {
            // The mock Payments triggers an error when com.example.invalid is
            // passed to it as store_item_id. Exercise it here
            previewPayments.widgetData = jsonPurchaseError;

            var button = findChild(previewPayments, "paymentButton");
            verify(button, "Button not found.");

            mouseClick(button);

            paymentClient.process();
            spy.wait();

            var args = spy.signalArguments[0];
            compare(args[0], "previewPayments");
            compare(args[1], "purchaseError");
            compare(args[2], jsonPurchaseError["source"]);
        }

        function test_purchase_cancelled() {
            // The mock Payments triggers cancellation when com.example.cancel
            // is passed to it as store_item_id. Exercise it here
            previewPayments.widgetData = jsonPurchaseCancel;

            var button = findChild(previewPayments, "paymentButton");
            var progress = findChild(previewPayments, "loadingBar");
            verify(button, "Button not found.");
            verify(progress, "Progress not found.");

            mouseClick(button);

            tryCompare(progress, "visible", true);
            tryCompare(progress, "opacity", 1);
            tryCompare(button, "visible", false);
            tryCompare(button, "opacity", 0);

            paymentClient.process();

            // Signal is not used at the moment, to avoid preview refresh.
            /*
             *spy.wait();
             *
             * var args = spy.signalArguments[0];
             * compare(args[0], "previewPayments");
             * compare(args[1], "purchaseCancelled");
             * compare(args[2], jsonPurchaseCancel["source"]);
             */

            tryCompare(progress, "visible", false);
            tryCompare(progress, "opacity", 0);
            tryCompare(button, "visible", true);
            tryCompare(button, "opacity", 1);
        }
    }
}
