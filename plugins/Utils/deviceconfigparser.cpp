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
#include <QStandardPaths>

DeviceConfigParser::DeviceConfigParser(QObject *parent): QObject(parent)
{
    // Local files have highest priority
    QString path;
    Q_FOREACH (const QString &standardPath, QStandardPaths::standardLocations(QStandardPaths::GenericConfigLocation)) {
        if (QFileInfo::exists(standardPath + "/devices.conf")) {
            path = standardPath + "/devices.conf";
            break;
        }
    }

    // Check if there is an override in the device tarball (/system/etc/)
    if (path.isEmpty() && QFileInfo::exists("/system/etc/ubuntu/devices.conf")) {
        path = "/system/etc/ubuntu/devices.conf";
    }

    // No higher priority files found. Use standard of /etc/
    if (path.isEmpty()) {
        path = "/etc/ubuntu/devices.conf";
    }

    qDebug() << "Using" << path << "as device configuration file";
    m_config = new QSettings(path, QSettings::IniFormat, this);
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

QString DeviceConfigParser::category() const
{
    QStringList supportedValues = {"phone", "tablet", "desktop"};
    m_config->beginGroup(m_name);
    QString value = m_config->value("Category", "phone").toString();
    if (!supportedValues.contains(value)) {
        qWarning().nospace().noquote() << "Unknown option \"" << value << "\" in " << m_config->fileName()
                    << ". Supported options are: " << supportedValues.join(", ") << ".";
        return "phone";
    }
    m_config->endGroup();
    return value;
}

QStringList DeviceConfigParser::readOrientationsFromConfig(const QString &key) const
{
    m_config->beginGroup(m_name);

    QStringList ret;
    if (m_config->contains(key)) {
        ret = m_config->value(key).toStringList();
    }

    m_config->endGroup();
    return ret;
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
        qWarning().nospace().noquote() << "Unknown option \"" << orientationString << "\" in " << m_config->fileName()
                    << ". Supported options are: Landscape, InvertedLandscape, Portrait and InvertedPortrait.";
    }
    return defaultValue;
}
