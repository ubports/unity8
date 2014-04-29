pragma Singleton
import QtQuick 2.2
import "CardCreator.js" as CardCreator

QtObject {
    id: root

    property var cache: new Object();

    function getCardComponent(template, components) {
        if (template === undefined || components === undefined)
            return undefined;

        var tString = JSON.stringify(template);
        var cString = JSON.stringify(components);
        var allString = tString + cString;
        var component = cache[allString];
        if (component === undefined) {
            console.log("Create", tString, cString);
            component = CardCreator.createCardComponent(root, template, components);
            cache[allString] = component;
        }
        return component;
    }
}