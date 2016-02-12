/*
 * Copyright 2016 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include "deviceconfigparser.h"

#include <QSettings>
#include <QFileInfo>
#include <QDebug>

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
        path = "/etc/ubuntu/devices.conf";
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
    if (!orientationString.isEmpty()) {
        // Some option we don't know. Give some hint on what went wrong.
        qWarning().nospace().noquote() << "Unknown option \"" << orientationString << "\". Supported options are: Landscape, InvertedLandscape, Portrait and InvertedPortrait.";
    }
    return defaultValue;
}
