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

#ifndef DEVICECONFIGPARSER_H
#define DEVICECONFIGPARSER_H

#include <QObject>
#include <QSettings>

class DeviceConfigParser: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY changed)

    Q_PROPERTY(Qt::ScreenOrientation primaryOrientation READ primaryOrientation NOTIFY changed)
    Q_PROPERTY(Qt::ScreenOrientations supportedOrientations READ supportedOrientations NOTIFY changed)
    Q_PROPERTY(Qt::ScreenOrientation landscapeOrientation READ landscapeOrientation NOTIFY changed)
    Q_PROPERTY(Qt::ScreenOrientation invertedLandscapeOrientation READ invertedLandscapeOrientation NOTIFY changed)
    Q_PROPERTY(Qt::ScreenOrientation portraitOrientation READ portraitOrientation NOTIFY changed)
    Q_PROPERTY(Qt::ScreenOrientation invertedPortraitOrientation READ invertedPortraitOrientation NOTIFY changed)
    Q_PROPERTY(QString category READ category NOTIFY changed)

public:
    DeviceConfigParser(QObject *parent = nullptr);

    QString name() const;
    void setName(const QString &name);

    Qt::ScreenOrientation primaryOrientation() const;
    Qt::ScreenOrientations supportedOrientations() const;
    Qt::ScreenOrientation landscapeOrientation() const;
    Qt::ScreenOrientation invertedLandscapeOrientation() const;
    Qt::ScreenOrientation portraitOrientation() const;
    Qt::ScreenOrientation invertedPortraitOrientation() const;
    QString category() const;

Q_SIGNALS:
    void changed();

private:
    QString m_name;
    QSettings *m_config;

    QStringList readOrientationsFromConfig(const QString &key) const;
    QString readOrientationFromConfig(const QString &key) const;
    Qt::ScreenOrientation stringToOrientation(const QString &orientationString, Qt::ScreenOrientation defaultValue) const;
};

#endif
