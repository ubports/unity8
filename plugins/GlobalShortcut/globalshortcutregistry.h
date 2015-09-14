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

#ifndef GLOBALSHORTCUT_REGISTRY_H
#define GLOBALSHORTCUT_REGISTRY_H

#include <QObject>
#include <QVariantList>
#include <QPointer>
#include <QWindow>

#include "globalshortcut.h"

typedef QMap<QVariant, QVector<QPointer<GlobalShortcut>>> GlobalShortcutList;

/**
 * @brief The GlobalShortcutRegistry class
 *
 * Serves as a central point for shortcut registration.
 */
class Q_DECL_EXPORT GlobalShortcutRegistry: public QObject
{
    Q_OBJECT
public:
    GlobalShortcutRegistry(QObject * parent = nullptr);
    ~GlobalShortcutRegistry() = default;

    /**
     * @return the list of shortcuts currently registered
     */
    GlobalShortcutList shortcuts() const;
    /**
     * @return whether shortcut @p seq is currently registered
     */
    bool hasShortcut(const QVariant &seq) const;
    /**
     * Adds a shortcut @p seq to the registry
     */
    void addShortcut(const QVariant &seq, GlobalShortcut * sc);

    /**
     * Sets up key events filtering on window @p wid
     */
    void setupFilterOnWindow(qulonglong wid);

protected:
    bool eventFilter(QObject *obj, QEvent *event) override;

private Q_SLOTS:
    void removeShortcut(QObject *obj);

private:
    GlobalShortcutList m_shortcuts;
    QPointer<QWindow> m_filteredWindow = nullptr;
};

#endif
