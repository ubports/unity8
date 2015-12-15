/*
 * Copyright 2014 Canonical Ltd.
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
 */

#ifndef ACTIONROOTSTATE_H
#define ACTIONROOTSTATE_H

#include "unityindicatorsglobal.h"

#include "rootstateparser.h"

class QDBusActionGroup;

class UNITYINDICATORS_EXPORT ActionRootState : public RootStateObject
{
    Q_OBJECT
    Q_PROPERTY(QDBusActionGroup* actionGroup READ actionGroup WRITE setActionGroup NOTIFY actionGroupChanged)
    Q_PROPERTY(QString actionName READ actionName WRITE setActionName NOTIFY actionNameChanged)

public:
    ActionRootState(QObject *parent = nullptr);

    QDBusActionGroup *actionGroup() const;
    void setActionGroup(QDBusActionGroup *actionGroup);

    QString actionName() const;
    void setActionName(const QString& actionName);

    bool valid() const override;

Q_SIGNALS:
    void actionGroupChanged();
    void actionNameChanged();

private Q_SLOTS:
    void updateActionState();

private:
    QDBusActionGroup* m_actionGroup;
    QString m_actionName;
};

#endif // ACTIONROOTSTATE_H
