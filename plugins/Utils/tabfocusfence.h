/*
 * Copyright 2017 Canonical Ltd.
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

#ifndef TABFOCUSFENCE_H
#define TABFOCUSFENCE_H

#include <QQuickItem>

// An item that restricts focus Tab travelling
// to its children
class TabFocusFenceItem : public QQuickItem
{
Q_OBJECT

public:
    TabFocusFenceItem(QQuickItem *parent = nullptr);

    Q_INVOKABLE bool focusNext();
    Q_INVOKABLE bool focusPrev();

    void keyPressEvent(QKeyEvent *event) override;
    void keyReleaseEvent(QKeyEvent *event) override;
};

#endif
