/*
 * Copyright (C) 2014 Canonical, Ltd.
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
 *
 * Author: Daniel d'Andrada <daniel.dandrada@canonical.com>
 */

#ifndef UNITY_WINDOWINPUTFILTER_H
#define UNITY_WINDOWINPUTFILTER_H

#include <QQuickItem>
#include <QPointer>

/*
   Receives all key events that arrive in the QQuickWindow where this item is placed.

   Rejected key events will be allowed to be processed normally by the QQuickWindow whereas
   accepted ones will be filtered out. Events are accepted by default, so make sure you reject
   the keys you're not interested in.

   If more than one WindowInputFilter exist in the same QML scene (and thus in the same QQuickWindow)
   they will be called in the order of creation, which can be tricky to assess. So the best practice
   is to have at most one WindowInputFilter per QML scene.
 */
class WindowInputFilter : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(ulong lastInputTimestamp READ lastInputTimestamp NOTIFY lastInputTimestampChanged)
public:
    WindowInputFilter(QQuickItem *parent = 0);

    bool eventFilter(QObject *watched, QEvent *event) override;

    ulong lastInputTimestamp() const;

Q_SIGNALS:
    void lastInputTimestampChanged();

private Q_SLOTS:
    void setupFilterOnWindow(QQuickWindow *window);

private:
    QPointer<QQuickWindow> m_filteredWindow;
    ulong m_lastInputTimestamp;
};

#endif // UNITY_WINDOWINPUTFILTER_H
