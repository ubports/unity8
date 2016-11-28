/*
 * Copyright 2015-2016 Canonical Ltd.
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

/**
 * @brief The Constants class
 *
 * This singleton class exposes contants to Qml
 *
 */

class Constants: public QObject
{
    Q_OBJECT
    Q_PROPERTY(int indicatorValueTimeout READ indicatorValueTimeout CONSTANT)
    Q_PROPERTY(QString defaultWallpaper READ defaultWallpaper CONSTANT)

public:
    Constants(QObject *parent = 0);

    int indicatorValueTimeout() const { return m_indicatorValueTimeout; }
    QString defaultWallpaper() const { return m_defaultWallpaper; }

private:
    int m_indicatorValueTimeout;
    QString m_defaultWallpaper;
};
