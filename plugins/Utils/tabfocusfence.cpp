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

#include "tabfocusfence.h"

#include <private/qquickitem_p.h>

TabFocusFenceItem::TabFocusFenceItem(QQuickItem *parent) : QQuickItem(parent)
{
    QQuickItemPrivate *d = QQuickItemPrivate::get(this);
    d->isTabFence = true;
    setFlag(ItemIsFocusScope);
}

bool TabFocusFenceItem::focusNext()
{
    QQuickItem * current = scopedFocusItem();
    if (current) {
        QQuickItem * next = current->nextItemInFocusChain(true);
        if (next) {
            next->setFocus(true, Qt::TabFocusReason);
            return true;
        }
    }
    return false;
}

bool TabFocusFenceItem::focusPrev()
{
    QQuickItem * current = scopedFocusItem();
    if (current) {
        QQuickItem * prev = current->nextItemInFocusChain(false);
        if (prev) {
            prev->setFocus(true, Qt::BacktabFocusReason);
            return true;
        }
    }
    return false;
}

void TabFocusFenceItem::keyPressEvent(QKeyEvent *event)
{
    // Needed so we eat Tab keys when there's only one item inside the fence
    if (event->key() == Qt::Key_Tab) {
        event->accept();
    } else {
        QQuickItem::keyPressEvent(event);
    }
}

void TabFocusFenceItem::keyReleaseEvent(QKeyEvent *event)
{
    // Needed so we eat Tab keys when there's only one item inside the fence
    if (event->key() == Qt::Key_Tab) {
        event->accept();
    } else {
        QQuickItem::keyReleaseEvent(event);
    }
}
