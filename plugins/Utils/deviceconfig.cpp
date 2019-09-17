/*
 * Copyright 2016 Canonical Ltd.
 *           2019 UBports foundation.
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

#include "deviceconfig.h"

#include <deviceinfo.h>
#include <QDebug>

DeviceConfig::DeviceConfig(QObject *parent):
    QObject(parent),
    m_info(std::make_shared<DeviceInfo>())
{
}

QString DeviceConfig::name() const
{
    return QString::fromStdString(m_info->name());
}

Qt::ScreenOrientation DeviceConfig::primaryOrientation() const
{
    return stringToOrientation(m_info->primaryOrientation(), Qt::PrimaryOrientation);
}

Qt::ScreenOrientations DeviceConfig::supportedOrientations() const
{
    auto values = m_info->supportedOrientations();
    if (values.empty()) {
        return Qt::PortraitOrientation
                | Qt::InvertedPortraitOrientation
                | Qt::LandscapeOrientation
                | Qt::InvertedLandscapeOrientation;
    }

    Qt::ScreenOrientations ret = Qt::PrimaryOrientation;
    for (auto orientationString : values) {
        ret |= stringToOrientation(orientationString, Qt::PrimaryOrientation);
    }
    return ret;
}

Qt::ScreenOrientation DeviceConfig::landscapeOrientation() const
{
    return stringToOrientation(m_info->landscapeOrientation(), Qt::LandscapeOrientation);
}

Qt::ScreenOrientation DeviceConfig::invertedLandscapeOrientation() const
{
    return stringToOrientation(m_info->invertedLandscapeOrientation(), Qt::InvertedLandscapeOrientation);
}

Qt::ScreenOrientation DeviceConfig::portraitOrientation() const
{
    return stringToOrientation(m_info->portraitOrientation(), Qt::PortraitOrientation);
}

Qt::ScreenOrientation DeviceConfig::invertedPortraitOrientation() const
{
    return stringToOrientation(m_info->invertedPortraitOrientation(), Qt::InvertedPortraitOrientation);
}

QString DeviceConfig::category() const
{
    QStringList supportedValues = {"phone", "tablet", "desktop"};
    QString value = QString::fromStdString(DeviceInfo::deviceTypeToString(m_info->deviceType()));
    if (!supportedValues.contains(value)) {
        qWarning().nospace().noquote() << "Unknown option \"" << value
                    << ". Supported options are: " << supportedValues.join(", ") << ".";
        return "phone";
    }
    return value;
}

Qt::ScreenOrientation DeviceConfig::stringToOrientation(const std::string &orientationString, Qt::ScreenOrientation defaultValue) const
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
    if (!orientationString.empty()) {
        // Some option we don't know. Give some hint on what went wrong.
        qWarning().nospace().noquote() << "Unknown option \"" << QString::fromStdString(orientationString)
                    << ". Supported options are: Landscape, InvertedLandscape, Portrait and InvertedPortrait.";
    }
    return defaultValue;
}

bool DeviceConfig::supportsMultiColorLed() const
{
    return m_info->contains("supportsMultiColorLed");
}
