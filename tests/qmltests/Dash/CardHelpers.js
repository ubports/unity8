.pragma library

var components = ["title", "art", "subtitle", "mascot", "emblem", "old-price", "price", "alt-price", "rating", "alt-rating", "summary"]

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
