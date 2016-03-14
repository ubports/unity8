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

#include <QDebug>
#include <QGuiApplication>
#include <QKeyEvent>
#include <QKeySequence>

#include "globalshortcutregistry.h"

static qulonglong s_windowId = 0;

GlobalShortcutRegistry::GlobalShortcutRegistry(QObject *parent)
    : QObject(parent)
{
}

GlobalShortcutList GlobalShortcutRegistry::shortcuts() const
{
    return m_shortcuts;
}

bool GlobalShortcutRegistry::hasShortcut(const QVariant &seq) const
{
    return m_shortcuts.contains(seq);
}

void GlobalShortcutRegistry::addShortcut(const QVariant &seq, GlobalShortcut *sc)
{
    if (sc) {
        if (!m_shortcuts.contains(seq)) { // create a new entry
            m_shortcuts.insert(seq, {sc});
        } else { // append to an existing one
            auto shortcuts = m_shortcuts[seq];
            shortcuts.append(sc);
            m_shortcuts.insert(seq, shortcuts);
        }

        connect(sc, &GlobalShortcut::destroyed, this, &GlobalShortcutRegistry::removeShortcut);
    }
}

void GlobalShortcutRegistry::removeShortcut(QObject *obj)
{
    QMutableMapIterator<QVariant, QVector<QPointer<GlobalShortcut>>> it(m_shortcuts);
    while (it.hasNext()) {
        it.next();
        GlobalShortcut * scObj = static_cast<GlobalShortcut *>(obj);
        if (scObj && it.value().contains(scObj)) {
            it.value().removeAll(scObj);
            if (it.value().isEmpty()) {
                it.remove();
            }
        }
    }
}

bool GlobalShortcutRegistry::eventFilter(QObject *obj, QEvent *event)
{
    Q_ASSERT(m_filteredWindow);
    Q_ASSERT(obj == static_cast<QObject*>(m_filteredWindow.data()));

    if (event->type() == QEvent::KeyPress) {
        QKeyEvent *keyEvent = static_cast<QKeyEvent*>(event);
        int seq = keyEvent->key() + keyEvent->modifiers();
        if (m_shortcuts.contains(seq)) {
            const auto shortcuts = m_shortcuts.value(seq);
            Q_FOREACH(const auto &shortcut, shortcuts) {
                if (shortcut) {
                    qApp->sendEvent(shortcut, keyEvent);
                    event->accept();
                }
            }
        }

        return event->isAccepted();
    }

    return QObject::eventFilter(obj, event);
}

void GlobalShortcutRegistry::setupFilterOnWindow(qulonglong wid)
{
    if (wid == s_windowId) {
        return;
    }

    if (m_filteredWindow) {
        m_filteredWindow->removeEventFilter(this);
        m_filteredWindow.clear();
        s_windowId = 0;
    }

    Q_FOREACH(QWindow *window, qApp->allWindows()) {
        if (window && window->winId() == wid) {
            m_filteredWindow = window;
            window->installEventFilter(this);
            s_windowId = wid;
            break;
        }
    }
}
