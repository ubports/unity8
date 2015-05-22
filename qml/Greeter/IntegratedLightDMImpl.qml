import QtQuick 2.3
import IntegratedLightDM 0.1 as LightDM

QtObject {
    property bool active: LightDM.Greeter.active
    property bool authenticated: LightDM.Greeter.authenticated
    property bool promptless: LightDM.Greeter.promptless
    property real userCount: LightDM.Users.count

    property var theGreeter: LightDM.Greeter
    property var infographicModel: LightDM.Infographic
    property var userModel: LightDM.Users

    function authenticate(user) {
        LightDM.Greeter.authenticate(user);
    }

    function getUser(uid) {
        return LightDM.Users.data(uid, LightDM.UserRoles.NameRole);
    }

    function infographicReadyForDataChange() {
        LightDM.Infographic.readyForDataChange();
    }

    function respond(response) {
        LightDM.Greeter.respond(response);
    }

    function showGreeter() {
        LightDM.Greeter.showGreeter();
    }

    function startSessionSync() {
        return LightDM.Greeter.startSessionSync();
    }
}
