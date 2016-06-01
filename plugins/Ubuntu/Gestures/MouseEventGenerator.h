/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef MOUSEEVENTGENERATOR_H
#define MOUSEEVENTGENERATOR_H

#include <QObject>
#include <QPointF>

#include "UbuntuGesturesQmlGlobal.h"

class QQuickItem;

class UBUNTUGESTURESQML_EXPORT MouseEventGenerator : public QObject {
    Q_OBJECT
    Q_PROPERTY(QQuickItem* targetItem MEMBER m_targetItem NOTIFY targetItemChanged)

public:
    MouseEventGenerator(QObject *parent = nullptr);

    Q_INVOKABLE void move(const QPointF position);
    Q_INVOKABLE void press(const QPointF position);
    Q_INVOKABLE void release(const QPointF position);

Q_SIGNALS:
    void targetItemChanged(QQuickItem *);

private:
    bool m_mousePressed {false};
    QQuickItem *m_targetItem {nullptr};

    friend class tst_FloatingFlickable;
};

#endif // MOUSEEVENTGENERATOR_H
