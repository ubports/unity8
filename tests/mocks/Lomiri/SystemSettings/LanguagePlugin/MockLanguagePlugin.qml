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

Item {
    property var languageNames: ["English (United States)", "French (France)", "Spanish (Spain)", "Spanish (Mexico)",
        "German (Switzerland)", "Czech (Czechia)", "Chinese (Hongkong)", "Chinese (Singapore)", "Chinese (China)"]
    property var languageCodes: ["en_US", "fr_FR", "es_ES", "es_MX", "de_CH", "cs_CZ", "zh_HK", "zh_SG", "zh_CN"]
    property int currentLanguage: 0
}
