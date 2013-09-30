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
 *
 * Author: Nick Dedekind <nick.dedekind@canonical.com>
 */

#ifndef UNITY_MENU_MODEL_PATHS_H
#define UNITY_MENU_MODEL_PATHS_H

#include <QVariant>

class UnityMenuModelPaths : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QVariant source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QByteArray busName READ busName NOTIFY busNameChanged)
    Q_PROPERTY(QVariantMap actions READ actions NOTIFY actionsChanged)
    Q_PROPERTY(QByteArray menuObjectPath READ menuObjectPath NOTIFY menuObjectPathChanged)

    Q_PROPERTY(QByteArray busNameHint READ busNameHint WRITE setBusNameHint NOTIFY busNameHintChanged)
    Q_PROPERTY(QByteArray actionsHint READ actionsHint WRITE setActionsHint NOTIFY actionsHintChanged)
    Q_PROPERTY(QByteArray menuObjectPathHint READ menuObjectPathHint WRITE setMenuObjectPathHint NOTIFY menuObjectPathHintChanged)

public:
    explicit UnityMenuModelPaths(QObject *parent = 0);

    QVariant source() const;
    void setSource(const QVariant& data);

    QByteArray busName() const;
    QVariantMap actions() const;
    QByteArray menuObjectPath() const;

    QByteArray busNameHint() const;
    QByteArray actionsHint() const;
    QByteArray menuObjectPathHint() const;

Q_SIGNALS:
    void sourceChanged();
    void busNameChanged();
    void actionsChanged();
    void menuObjectPathChanged();

    void busNameHintChanged();
    void actionsHintChanged();
    void menuObjectPathHintChanged();

private:
    void setBusName(const QByteArray &name);
    void setActions(const QVariantMap& actions);
    void setMenuObjectPath(const QByteArray &path);

    void setBusNameHint(const QByteArray& nameHint);
    void setActionsHint(const QByteArray &actionsHint);
    void setMenuObjectPathHint(const QByteArray &pathHint);

    void updateData();

    QVariant m_sourceData;
    QByteArray m_busName;
    QVariantMap m_actions;
    QByteArray m_menuObjectPath;

    QByteArray m_busNameHint;
    QByteArray m_actionsHint;
    QByteArray m_menuObjectPathHint;
};

#endif // UNITY_MENU_MODEL_PATHS_H
