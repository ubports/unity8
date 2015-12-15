/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#include "activefocuslogger.h"

#include <QQuickWindow>

ActiveFocusLogger::ActiveFocusLogger(QQuickItem *parent)
    : QQuickItem(parent)
{
    connect(this, &QQuickItem::windowChanged,
            this, &ActiveFocusLogger::setupFilterOnWindow);
}

void ActiveFocusLogger::setupFilterOnWindow(QQuickWindow *window)
{
    if (!m_window.isNull()) {
        disconnect(m_window.data(), nullptr, this, nullptr);
        m_window.clear();
    }

    if (window) {
        m_window = window;
        QObject::connect(window, &QQuickWindow::activeFocusItemChanged,
                this, &ActiveFocusLogger::printActiveFocusInfo);
    }
}

void ActiveFocusLogger::printActiveFocusInfo()
{
    if (!m_window || !isEnabled()) {
        return;
    }

    qDebug() << "============== Active focus info START ================";
    if (m_window->activeFocusItem()) {
        qDebug() << m_window->activeFocusItem();
        qDebug() << "Ancestry:";
        QQuickItem *item = m_window->activeFocusItem()->parentItem();
        while (item != nullptr) {
            qDebug() << item << ", isFocusScope =" << item->isFocusScope();
            item = item->parentItem();
        }
    } else {
        qDebug() << "NULL";
    }
    qDebug() << "============== Active focus info END ================";
}
