import QtQuick 2.4
import Ubuntu.Components 1.3
import "../Components"

FocusScope {
    id: root
    focus: true

    property string text
    property bool isSecret
    property bool interactive: true
    property bool loginError: false
    property bool hasKeyboard: false
    property alias enteredText: passwordInput.text
    property alias inputFocus: passwordInput.focus

    signal clicked()
    signal canceled()
    signal accepted(string response)

    StyledItem {
        id: d

        readonly property color textColor: passwordInput.enabled ? theme.palette.normal.raisedText
                                                                 : theme.palette.disabled.raisedText
        readonly property color selectedColor: passwordInput.enabled ? theme.palette.normal.raised
                                                                     : theme.palette.disabled.raised
        readonly property color drawColor: passwordInput.enabled ? theme.palette.normal.raisedSecondaryText
                                                                 : theme.palette.disabled.raisedSecondaryText
        readonly property color errorColor: passwordInput.enabled ? theme.palette.normal.negative
                                                                  : theme.palette.disabled.negative
    }

    function showFakePassword() {
        // Just a silly hack for looking like 4 pin numbers got entered, if
        // a fingerprint was used and we happen to be using a pin.  This was
        // a request from Design.
        if (isSecret) {
            passwordInput.text = "...."; // actual text doesn't matter
        }
    }

    TextField {
        id: passwordInput
        objectName: "promptField"
        anchors.left: extraIcons.left

        opacity: fakeLabel.visible ? 0 : 1
        activeFocusOnTab: true

        onSelectedTextChanged: passwordInput.deselect()
        onCursorPositionChanged: cursorPosition = length

        validator: RegExpValidator {
            regExp: /^\d{4}$/
        }

        inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText |
                          Qt.ImhMultiLine | // so OSK doesn't close on Enter
                          Qt.ImhDigitsOnly
        echoMode: root.isSecret ? TextInput.Password : TextInput.Normal
        hasClearButton: false

        cursorDelegate: Item {}

        passwordCharacter: "●"
        color: d.drawColor

        readonly property real letterSpacing: units.gu(1.75)
        readonly property real frameSpacing: letterSpacing

        font.pixelSize: units.gu(2.5)
        font.letterSpacing: letterSpacing

        style: StyledItem {
            anchors.fill: parent
            styleName: "FocusShape"

            // Properties needed by TextField
            readonly property color color: d.textColor
            readonly property color selectedTextColor: d.selectedColor
            readonly property color selectionColor: d.textColor
            readonly property color borderColor: "transparent"
            readonly property color backgroundColor: "transparent"
            readonly property color errorColor: d.errorColor
            readonly property real frameSpacing: 0

            // Properties needed by FocusShape
            readonly property bool enabled: styledItem.enabled
            readonly property bool keyNavigationFocus: styledItem.keyNavigationFocus
            property bool activeFocusOnTab
        }

        onDisplayTextChanged: {
            // We use onDisplayTextChanged instead of onTextChanged because
            // displayText changes after text and if we did this before it
            // updated, we would use the wrong displayText for fakeLabel.
            root.loginError = false;
            if (text.length >= 4) {
                // hard limit of 4 for passcodes right now
                respond();
            }
        }

        onAccepted: respond()

        function respond() {
            if (root.interactive) {
                root.accepted(passwordInput.text);
            }
        }

        Keys.onEscapePressed: {
            root.canceled();
            event.accepted = true;
        }
    }

    Row {
        id: extraIcons
        spacing: passwordInput.frameSpacing
        anchors {
            horizontalCenter: parent ? parent.horizontalCenter : undefined
            horizontalCenterOffset: passwordInput.letterSpacing / 2
            verticalCenter: passwordInput ? passwordInput.verticalCenter  : undefined
        }

        Label {
            id: pinHint
            objectName: "promptPinHint"

            text: "○○○○"
            visible: !passwordInput.inputMethodComposing
            enabled: visible
            color: loginError ? d.errorColor : d.drawColor
            font {
                pixelSize: units.gu(2.5)
                letterSpacing: units.gu(1.75)
            }
            elide: Text.ElideRight
        }
        Icon {
            name: "keyboard-caps-enabled"
            height: units.gu(3)
            width: height
            color: d.drawColor
            visible: root.isSecret && false // TODO: detect when caps lock is on
            anchors.verticalCenter: parent.verticalCenter
        }
        Icon {
            objectName: "greeterPromptKeyboardButton"
            name: "input-keyboard-symbolic"
            height: units.gu(3)
            width: height
            color: d.drawColor
            visible: !unity8Settings.alwaysShowOsk && root.hasKeyboard
            anchors.verticalCenter: parent.verticalCenter
            MouseArea {
                anchors.fill: parent
                onClicked: unity8Settings.alwaysShowOsk = true
            }
        }
        Icon {
            name: "dialog-warning-symbolic"
            height: units.gu(3)
            width: height
            color: d.drawColor
            visible: root.loginError
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Have a fake label that covers the text field after the user presses
    // enter.  What we *really* want is a disabled mode that doesn't lose OSK
    // focus.  Because our goal here is simply to keep the OSK up while
    // we wait for PAM to get back to us, and while waiting, we don't want
    // the user to be able to edit the field (simply because it would look
    // weird if we allowed that).  But until we have such a disabled mode,
    // we'll fake it by covering the real text field with a label.
    FadingLabel {
        id: fakeLabel
        anchors.verticalCenter: extraIcons ? extraIcons.verticalCenter : undefined
        anchors.left: extraIcons ? extraIcons.left : undefined
        anchors.right: parent ? parent.right : undefined
        anchors.rightMargin: passwordInput.frameSpacing * 2 + extraIcons.width
        color: d.drawColor
        font {
            pixelSize: pinHint.font.pixelSize
            letterSpacing: pinHint.font.letterSpacing
        }
        text: passwordInput.displayText
        visible: !root.interactive
        enabled: visible
    }
}
