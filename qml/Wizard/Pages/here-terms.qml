/*
 * Copyright (C) 2014,2015 Canonical, Ltd.
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
import AccountsService 0.1
import Qt.labs.folderlistmodel 2.1
import Ubuntu.Components 1.3
import Ubuntu.Web 0.2
import ".." as LocalComponents

LocalComponents.Page {
    objectName: "hereTermsPage"

    title: i18n.tr("Terms & Conditions")
    customBack: true

    FolderListModel {
        id: termsModel
        folder: AccountsService.hereLicensePath
        nameFilters: ["*.html"]
        showDirs: false
        showOnlyReadable: true
        onCountChanged: loadFileContent()
    }

    function makeFileName(lang, country) {
        return lang + "_" + country + ".html"
    }

    function defaultCountryForLanguage(lang) {
        if (lang === "da") return "DK"
        if (lang === "en") return "US"
        if (lang === "ko") return "KR"
        if (lang === "zh") return "CN"
        return lang.toUpperCase()
    }

    function determineFileName() {
        var codes = i18n.language.split(".")[0].split("_")
        var defaultCountry = defaultCountryForLanguage(codes[0])
        if (codes.count === 1)
            codes = [codes[0], defaultCountry]
        var perfectMatch = makeFileName(codes[0], codes[1])
        var nearMatch = makeFileName(codes[0], defaultCountry)
        var nearMatchExists = false

        for (var i = 0; i < termsModel.count; i++) {
            var fileName = termsModel.get(i, "fileName")
            if (fileName == perfectMatch) {
                return perfectMatch
            } else if (fileName == nearMatch) {
                nearMatchExists = true
            }
        }

        if (nearMatchExists) {
            return nearMatch
        } else {
            return makeFileName("en", "US")
        }
    }

    function loadFileContent() {
        var xhr = new XMLHttpRequest
        xhr.open("GET", AccountsService.hereLicensePath + "/" + determineFileName())
        xhr.onreadystatechange = function() {
            if (xhr.readyState == XMLHttpRequest.DONE) {
                termsLabel.text = xhr.responseText
            }
        }
        xhr.send()
    }

    onBackClicked: {
        if (webview.visible) {
            termsLabel.visible = true
        } else {
            pageStack.prev()
        }
    }

    Column {
        id: column
        anchors.fill: content

        Label {
            id: termsLabel
            objectName: "termsLabel"
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.Wrap
            linkColor: theme.palette.normal.foregroundText
            onLinkActivated: {
                webview.url = link
                termsLabel.visible = false
            }
        }

        WebView {
            id: webview
            objectName: "webview"
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height
            visible: !termsLabel.visible
        }
    }
}
