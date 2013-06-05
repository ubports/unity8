/*
 * Copyright (C) 2012, 2013 Canonical, Ltd.
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

#ifndef HUDCLIENTSTUB_H
#define HUDCLIENTSTUB_H

#include <QObject>

#include <QVariantMap>

#include <hud-client.h>

class HudClientStub : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int lastExecutedToolbarItem READ lastExecutedToolbarItem)
    Q_PROPERTY(QString lastSetQuery READ lastSetQuery)
    Q_PROPERTY(int lastExecutedCommandRow READ lastExecutedCommandRow)
    Q_PROPERTY(int lastExecutedParametrizedCommandRow READ lastExecutedParametrizedCommandRow)
    Q_PROPERTY(bool lastParametrizedCommandCommited READ lastParametrizedCommandCommited)
    Q_PROPERTY(QVariantMap activatedActions READ activatedActions)

public:
    int lastExecutedToolbarItem() const;
    QString lastSetQuery() const;
    int lastExecutedCommandRow() const;
    int lastExecutedParametrizedCommandRow() const;
    bool lastParametrizedCommandCommited() const;
    QVariantMap activatedActions() const;

    Q_INVOKABLE void reset();
    Q_INVOKABLE int fullScreenToolbarItemValue() const;
    Q_INVOKABLE int helpToolbarItemValue() const;
    Q_INVOKABLE int preferencesToolbarItemValue() const;
    Q_INVOKABLE int undoToolbarItemValue() const;
    Q_INVOKABLE void setHelpToolbarItemEnabled(bool enabled) const;

    static HudClientQuery *m_query;
    static guint m_querySignalToolbarUpdated;
    static int m_lastExecutedToolbarItem;
    static QString m_lastSetQuery;
    static int m_lastExecutedCommandRow;
    static int m_lastExecutedParametrizedCommandRow;
    static bool m_lastParametrizedCommandCommited;
    static QVariantMap m_activatedActions;
    static bool m_helpToolbarItemEnabled;
};


#endif
