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

#include "widgetsmap.h"

/*!
    \qmltype WidgetsMap
    \inherits QObject

    \brief The WidgetsMap class defines a auxiliary map class with all widgets registered by the plugins.

    \b {This component is under heavy development.}

    \code
    PluginModel {
        id: menuModel
        baseDir: "/usr/share/indicators"
    }

    ListView {
        id: view
        model: menuModel
        delegate: menuModel.widgetsMap.find("myWidget")
        Component.onCompleted: menuModel.load()
    }
    \endcode
*/
WidgetsMap::WidgetsMap(QObject *parent)
    :QObject(parent)
{
}

/*! \internal */
void WidgetsMap::append(WidgetsMapType types)
{
    Q_FOREACH(QString key, types.keys()) {
        m_map.insert(key, types[key]);
    }
}

/*! \internal */
void WidgetsMap::clear()
{
    m_map.clear();
}

/*!
    \qmlmethod WidgetsMap::map()

    Return a QVariantMap with the WidgetsMap contents.
*/
WidgetsMapType WidgetsMap::map() const
{
    return m_map;
}

/*!
    \qmlmethod WidgetsMap::find(QString widgetType)

    Look for a widgetType registered by any plugin and return the file that represent
    this type, or a empty QUrl if the type does not exists.
*/
QUrl WidgetsMap::find(const QString &widget) const
{
    return m_map[widget];
}
