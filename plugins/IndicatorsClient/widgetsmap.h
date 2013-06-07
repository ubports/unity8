/*
 * Copyright 2012 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 */

#ifndef WIDGETSMAP_H
#define WIDGETSMAP_H

#include <QObject>
#include <QMap>
#include <QString>
#include <QUrl>

typedef QMap<QString, QUrl> WidgetsMapType;

class WidgetsMap : public QObject
{
    Q_OBJECT
public:
    WidgetsMap(QObject *parent=0);

    void append(WidgetsMapType types);
    void clear();

    Q_INVOKABLE WidgetsMapType map() const;
    Q_INVOKABLE QUrl find(const QString &widget) const;

private:
    WidgetsMapType m_map;
};

#endif
