#include "deviceconfigparser.h"

#include <QSettings>
#include <QFileInfo>

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
    return stringToOrientation(readOrientationFromConfig("PrimaryOrientation"), Qt::PrimaryOrientation);
}

Qt::ScreenOrientations DeviceConfigParser::supportedOrientations() const
{
    QStringList values = readOrientationsFromConfig("SupportedOrientations");
    if (values.isEmpty()) {
        return Qt::PortraitOrientation
                | Qt::InvertedPortraitOrientation
                | Qt::LandscapeOrientation
                | Qt::InvertedLandscapeOrientation;
    }

    Qt::ScreenOrientations ret = Qt::PrimaryOrientation;
    Q_FOREACH(const QString &orientationString, values) {
        ret |= stringToOrientation(orientationString, Qt::PrimaryOrientation);
    }
    return ret;
}

Qt::ScreenOrientation DeviceConfigParser::landscapeOrientation() const
{
    return stringToOrientation(readOrientationFromConfig("LandscapeOrientation"), Qt::LandscapeOrientation);
}

Qt::ScreenOrientation DeviceConfigParser::invertedLandscapeOrientation() const
{
    return stringToOrientation(readOrientationFromConfig("InvertedLandscapeOrientation"), Qt::InvertedLandscapeOrientation);
}

Qt::ScreenOrientation DeviceConfigParser::portraitOrientation() const
{
    return stringToOrientation(readOrientationFromConfig("PortraitOrientation"), Qt::PortraitOrientation);
}

Qt::ScreenOrientation DeviceConfigParser::invertedPortraitOrientation() const
{
    return stringToOrientation(readOrientationFromConfig("InvertedPortraitOrientation"), Qt::InvertedPortraitOrientation);
}

QStringList DeviceConfigParser::readOrientationsFromConfig(const QString &key) const
{
    QFileInfo fi("./devices.conf");
    QString path;
    if (fi.exists()) {
        path = "./devices.conf";
    } else {
        path = "/etc/unity8/devices.conf";
    }
    QSettings config(path, QSettings::IniFormat);
    config.beginGroup(m_name);

    if (config.contains(key)) {
        return config.value(key).toStringList();
    }
    return QStringList();
}

QString DeviceConfigParser::readOrientationFromConfig(const QString &key) const
{
    QStringList ret = readOrientationsFromConfig(key);
    return ret.count() > 0 ? ret.first() : QString();
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
