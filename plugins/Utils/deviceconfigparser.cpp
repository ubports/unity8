#include "deviceconfigparser.h"

#include <QSettings>
#include <QSettings>

DeviceConfigParser::DeviceConfigParser(QObject *parent): QObject(parent)
{

}

QString DeviceConfigParser::name() const
{
    return m_name;
}

void DeviceConfigParser::setName(const QString &name)
{
    if (m_name == name) {
        return;
    }
    m_name = name;
    Q_EMIT changed();
}

Qt::ScreenOrientation DeviceConfigParser::primaryOrientation() const
{
    return stringToOrientation(readOrientationStringFromConfig("PrimaryOrientation"), Qt::PrimaryOrientation);
}

Qt::ScreenOrientations DeviceConfigParser::supportedOrientations() const
{
    QString values = readOrientationStringFromConfig("SupportedOrientations");
    if (values.isEmpty()) {
        return Qt::PortraitOrientation
                | Qt::InvertedPortraitOrientation
                | Qt::LandscapeOrientation
                | Qt::InvertedLandscapeOrientation;
    }

    Qt::ScreenOrientations ret = Qt::PrimaryOrientation;
    Q_FOREACH(const QString &orientationString, values.split(',')) {
        ret |= stringToOrientation(orientationString, Qt::PrimaryOrientation);
    }
    return ret;
}

Qt::ScreenOrientation DeviceConfigParser::landscapeOrientation() const
{
    return stringToOrientation(readOrientationStringFromConfig("LandscapeOrientation"), Qt::LandscapeOrientation);
}

Qt::ScreenOrientation DeviceConfigParser::invertedLandscapeOrientation() const
{
    return stringToOrientation(readOrientationStringFromConfig("InvertedLandscapeOrientation"), Qt::InvertedLandscapeOrientation);
}

Qt::ScreenOrientation DeviceConfigParser::portraitOrientation() const
{
    return stringToOrientation(readOrientationStringFromConfig("PortraitOrientation"), Qt::PortraitOrientation);
}

Qt::ScreenOrientation DeviceConfigParser::invertedPortraitOrientation() const
{
    return stringToOrientation(readOrientationStringFromConfig("InvertedPortraitOrientation"), Qt::InvertedPortraitOrientation);
}

QString DeviceConfigParser::readOrientationStringFromConfig(const QString &key) const
{
    QSettings config("/etc/unity8/devices.conf", QSettings::IniFormat);
    config.beginGroup(m_name);

    if (config.contains(key)) {
        return config.value(key).toString();
    }
    return QString();
}

Qt::ScreenOrientation DeviceConfigParser::stringToOrientation(const QString &orientationString, Qt::ScreenOrientation defaultValue) const
{
    if (orientationString == "Landscape") {
        return Qt::LandscapeOrientation;
    }
    if (orientationString == "InvertedLandscape") {
        return Qt::InvertedLandscapeOrientation;
    }
    if (orientationString == "Portrait") {
        return Qt::PortraitOrientation;
    }
    if (orientationString == "InvertedPortrait") {
        return Qt::InvertedPortraitOrientation;
    }
    return defaultValue;
}
