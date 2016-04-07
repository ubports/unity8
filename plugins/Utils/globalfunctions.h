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

#ifndef GLOBALFUNCTIONS_H
#define GLOBALFUNCTIONS_H

#include <QObject>
#include <QJSValue>
class QQuickItem;

/**
 * @brief The GlobalFunctions class
 *
 * This singleton class exposes utility functions to QML
 *
 */
class GlobalFunctions : public QObject
{
    Q_OBJECT
public:
    explicit GlobalFunctions(QObject *parent = 0);

    static Q_INVOKABLE QQuickItem* itemAt(QQuickItem* parent,
                                          int x,
                                          int y,
                                          QJSValue matcher);
};

#endif // GLOBALFUNCTIONS_H
