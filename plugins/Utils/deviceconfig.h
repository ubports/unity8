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

#pragma once

#include <QObject>
#include <memory>

class DeviceInfo;
class DeviceConfig: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name NOTIFY changed)

    // NOTE: When changing this properties, also update the examples in docs and data
    Q_PROPERTY(Qt::ScreenOrientation primaryOrientation READ primaryOrientation NOTIFY changed)
    Q_PROPERTY(Qt::ScreenOrientations supportedOrientations READ supportedOrientations NOTIFY changed)
    Q_PROPERTY(Qt::ScreenOrientation landscapeOrientation READ landscapeOrientation NOTIFY changed)
    Q_PROPERTY(Qt::ScreenOrientation invertedLandscapeOrientation READ invertedLandscapeOrientation NOTIFY changed)
    Q_PROPERTY(Qt::ScreenOrientation portraitOrientation READ portraitOrientation NOTIFY changed)
    Q_PROPERTY(Qt::ScreenOrientation invertedPortraitOrientation READ invertedPortraitOrientation NOTIFY changed)
    Q_PROPERTY(QString category READ category NOTIFY changed)
    Q_PROPERTY(bool supportsMultiColorLed READ supportsMultiColorLed)

public:
    DeviceConfig(QObject *parent = nullptr);

    QString name() const;

    Qt::ScreenOrientation primaryOrientation() const;
    Qt::ScreenOrientations supportedOrientations() const;
    Qt::ScreenOrientation landscapeOrientation() const;
    Qt::ScreenOrientation invertedLandscapeOrientation() const;
    Qt::ScreenOrientation portraitOrientation() const;
    Qt::ScreenOrientation invertedPortraitOrientation() const;
    QString category() const;
    bool supportsMultiColorLed() const;

Q_SIGNALS:
    void changed();

private:
    std::shared_ptr<DeviceInfo> m_info;

    Qt::ScreenOrientation stringToOrientation(const std::string &orientationString, Qt::ScreenOrientation defaultValue) const;
};
