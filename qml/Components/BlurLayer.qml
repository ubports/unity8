import QtQuick 2.4
import QtGraphicalEffects 1.0

Item {
    id: root

    property alias source: shaderEffectSource.sourceItem
    property alias saturation: desaturateEffect.saturationValue
    property alias blurRadius: fastBlur.radius

    readonly property alias ready: shaderEffectSource.ready

    ShaderEffect {
        id: desaturateEffect
        anchors.fill: root

        property real saturationValue: 1

        property variant source: ShaderEffectSource {
            id: shaderEffectSource
            hideSource: root.visible
            live: !root.visible
            property bool ready: false;
            onLiveChanged: {
                if (!live) {
                    ready = false;
                    scheduleUpdate();
                }
            }
            onScheduledUpdateCompleted: ready = true;
        }

        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform sampler2D source;
            uniform lowp float saturationValue;
            void main(void)
            {
                highp vec4 sourceColor = texture2D(source, qt_TexCoord0);
                highp vec4 scaledColor = sourceColor * vec4(0.3, 0.59, 0.11, 1.0);
                float luminance = scaledColor.r + scaledColor.g + scaledColor.b ;
                gl_FragColor = mix(vec4(luminance, luminance, luminance, sourceColor.a), sourceColor, saturationValue);
            }"
    }

    FastBlur {
        id: fastBlur
        anchors.fill: parent
        source: desaturateEffect
        visible: radius > 0
        radius: 0
    }
}
