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

#include "globalfunctions.h"

#include <QQmlEngine>
#include <private/qquickitem_p.h>

GlobalFunctions::GlobalFunctions(QObject *parent)
    : QObject(parent)
{
}

QQuickItem *GlobalFunctions::itemAt(QQuickItem* parent, int x, int y, QJSValue matcher)
{
    if (!parent) return nullptr;
    QList<QQuickItem *> children = QQuickItemPrivate::get(parent)->paintOrderChildItems();

    for (int i = children.count() - 1; i >= 0; --i) {
        QQuickItem *child = children.at(i);

        // Map coordinates to the child element's coordinate space
        QPointF point = parent->mapToItem(child, QPointF(x, y));
        if (child->isVisible() && point.x() >= 0
                && child->width() >= point.x()
                && point.y() >= 0
                && child->height() >= point.y()) {
            if (!matcher.isCallable()) return child;

            QQmlEngine* engine = qmlEngine(child);
            if (!engine) return child;

            QJSValue newObj = engine->newQObject(child);
            if (matcher.call(QJSValueList() << newObj).toBool()) {
                return child;
            }
        }
    }
    return nullptr;
}
