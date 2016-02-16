/*
 * Copyright 2013-2016 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

#ifndef MODELACTIONROOTSTATE_H
#define MODELACTIONROOTSTATE_H

#include "unityindicatorsglobal.h"

#include "rootstateparser.h"

class UnityMenuModel;

class UNITYINDICATORS_EXPORT ModelActionRootState : public RootStateObject
{
    Q_OBJECT
    Q_PROPERTY(UnityMenuModel* menu READ menu WRITE setMenu NOTIFY menuChanged)
    Q_PROPERTY(QString secondaryAction READ secondaryAction NOTIFY secondaryActionChanged)
    Q_PROPERTY(QString scrollAction READ scrollAction NOTIFY scrollActionChanged)
    Q_PROPERTY(QString submenuAction READ submenuAction NOTIFY submenuActionChanged)
public:
    ModelActionRootState(QObject *parent = 0);
    virtual ~ModelActionRootState();

    UnityMenuModel* menu() const;
    void setMenu(UnityMenuModel* menu);

    QString secondaryAction() const;
    QString scrollAction() const;
    QString submenuAction() const;

    bool valid() const override;

Q_SIGNALS:
    void menuChanged();
    void secondaryActionChanged();
    void scrollActionChanged();
    void submenuActionChanged();

private Q_SLOTS:
    void onModelRowsAdded(const QModelIndex& parent, int start, int end);
    void onModelRowsRemoved(const QModelIndex& parent, int start, int end);
    void onModelDataChanged(const QModelIndex& topLeft, const QModelIndex& bottomRight, const QVector<int>&);
    void reset();

private:
    void updateActionState();
    void updateOtherActions();

    UnityMenuModel* m_menu;
    QString m_secondaryAction;
    QString m_scrollAction;
    QString m_submenuAction;
    bool m_reentryGuard;
};

#endif // MODELACTIONROOTSTATE_H
