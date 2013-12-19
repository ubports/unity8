/*
 * Copyright (C) 2012, 2013 Canonical, Ltd.
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

import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    property string contextSnippetText
    property variant contextSnippetHighlights
    property string nameText
    property variant nameHighlights

    function highlightedText(text, highlights) {
        var hText = "";
        var nextIndexToProcess = 0;
        if (highlights && highlights.length % 2 == 0) {
            for (var i = 0; i < highlights.length - 1; i += 2) {
                var highlightStart = highlights[i];
                var highlightEnd = highlights[i + 1];
                if (highlightEnd < highlightStart)
                    continue;
                if (highlightStart < nextIndexToProcess)
                    continue;
                if (highlightStart != nextIndexToProcess) {
                    // Prev non marked text
                    hText += text.substr(nextIndexToProcess, highlightStart - nextIndexToProcess);
                }

                // Marked text
                hText += "<font color=\"#ffffff\">" + text.substr(highlightStart, highlightEnd - highlightStart + 1) + "</font>";
                nextIndexToProcess = highlightEnd + 1;
            }
        }
        if (nextIndexToProcess != text.length) {
            // End non marked text
            hText += text.substr(nextIndexToProcess);
        }
        return hText;
    }

    Label {
        id: actionLabel
        objectName: "actionLabel"
        anchors.left: parent.left
        anchors.leftMargin: units.gu(1)
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width / 2
        fontSize: "medium"
        elide: Text.ElideRight
        maximumLineCount: 1
        text: highlightedText(nameText, nameHighlights)
        color: "#80ffffff"
    }

    Label {
        horizontalAlignment: Text.AlignRight
        id: contextSnippetLabel
        objectName: "contextSnippetLabel"
        width: parent.width / 2 - units.gu(1)
        visible: text != ""
        anchors.right: parent.right
        anchors.rightMargin: units.gu(1)
        anchors.verticalCenter: parent.verticalCenter
        fontSize: "small"
        opacity: 0.5
        elide: Text.ElideRight
        maximumLineCount: 2
        text: highlightedText(contextSnippetText, contextSnippetHighlights)
        color: "#80ffffff"
    }
}
