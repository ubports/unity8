/*
 * Copyright 2015 Canonical Ltd.
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

#ifndef CONSTANTS_H
#define CONSTANTS_H

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

public:
    Constants(QObject *parent = 0);

    int indicatorValueTimeout() const { return m_indicatorValueTimeout; }

private:
    int m_indicatorValueTimeout;
};

#endif
