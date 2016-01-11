/*
 * Copyright (C) 2013 Canonical, Ltd.
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

.pragma library

var components = ["title", "art", "subtitle", "mascot", "emblem", "summary", "attributes", "overlayColor", "quickPreviewData"]

var defaultLayout = ' \
{ \
  "schema-version": 1, \
  "template": { \
    "category-layout": "grid", \
    "card-layout": "vertical", \
    "card-size": "medium", \
    "overlay-mode": null, \
    "collapsed-rows": 2 \
  }, \
  "components": { \
    "title": null, \
    "art": { \
        "aspect-ratio": 1.0 \
    }, \
    "subtitle": null, \
    "overlayColor": null, \
    "mascot": null, \
    "emblem": null, \
    "summary": null, \
    "attributes": { "max-count": 2 } \
  }, \
  "resources": {} \
}'

var fullMapping = ' \
{ \
  "title": "title", \
  "art": "art", \
  "subtitle": "subtitle", \
  "mascot": "mascot", \
  "emblem": "emblem", \
  "overlayColor": "overlayColor", \
  "summary": "summary", \
  "attributes": "attributes" \
}'


function tryParse(json, errorLabel) {
    var o = undefined;
    if (errorLabel !== undefined) {
        errorLabel.text = "";
    }
    try {
        o = JSON.parse(json)
    } catch(err) {
        if (errorLabel !== undefined) {
            errorLabel.text = err + "";
        } else {
            console.debug(err);
        }
    }
    return o;
}

function mapData(json, layout, errorLabel) {
    var o = tryParse(json, errorLabel);
    var d = undefined;

    if (o !== undefined) {
        d = Object();
        for (var k in components) {
            try {
                if (typeof layout[components[k]] == "object") {
                    d[components[k]] = o[layout[components[k]]['field']];
                } else {
                    d[components[k]] = o[layout[components[k]]];
                }
            } catch(err) {
                d[components[k]] = undefined;
            }
        }
    }
    return d;
}

function update(object, overrides) {
    for (var k in overrides) {
        if (typeof object[k] == "string" && typeof overrides[k] == "object") {
            if (!overrides[k].hasOwnProperty('field')) overrides[k]['field'] = object[k];
        }
        if (object[k] === null) {
            object[k] = overrides[k];
        } else if (typeof object[k] == "object" && typeof overrides[k] == "string") {
            object[k]['field'] = overrides[k];
        } else if (typeof object[k] == "object") {
            update(object[k], overrides[k]);
        } else {
            object[k] = overrides[k];
        }
    }
    return object;
}
