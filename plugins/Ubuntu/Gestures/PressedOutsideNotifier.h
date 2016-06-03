/*
 * Copyright (C) 2013 Canonical, Ltd.
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

#ifndef PRESSED_OUTSIDE_NOTIFIER_H
#define PRESSED_OUTSIDE_NOTIFIER_H

#include <QQuickItem>

#include <QQuickWindow>
#include <QPointer>
#include <QTimer>

#include <ubuntugesturesglobal.h>

/*
   Notifies when a point, mouse or touch, is pressed outside its area.

   Only enable it while needed.
 */
class UBUNTUGESTURES_EXPORT PressedOutsideNotifier : public QQuickItem {
    Q_OBJECT

public:
    PressedOutsideNotifier(QQuickItem * parent = nullptr);

    // From QObject
    bool eventFilter(QObject *watched, QEvent *event) override;

Q_SIGNALS:
    void pressedOutside();

protected:
    void itemChange(ItemChange change, const ItemChangeData &value) override;

private Q_SLOTS:
    void setupOrTearDownEventFiltering();

private:
    void setupEventFiltering();
    void tearDownEventFiltering();
    void processFilteredTouchBegin(QTouchEvent *event);

    QPointer<QQuickWindow> m_filteredWindow;

    // Emits pressedOutside() signal on timeout
    QTimer m_signalEmissionTimer;
};

#endif // PRESSED_OUTSIDE_NOTIFIER_H
