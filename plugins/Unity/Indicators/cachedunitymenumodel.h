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
 *
 * Authors:
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

#ifndef CACHEDUNITYMENUMODEL_H
#define CACHEDUNITYMENUMODEL_H

 #include <QObject>
 #include <QVariantMap>

class UnityMenuModel;

class CachedUnityMenuModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(UnityMenuModel* model READ model NOTIFY modelChanged)
    Q_PROPERTY(QString busName READ busName WRITE setBusName NOTIFY busNameChanged)
    Q_PROPERTY(QVariantMap actions READ actions WRITE setActions NOTIFY actionsChanged)
    Q_PROPERTY(QString menuObjectPath READ menuObjectPath WRITE setMenuObjectPath NOTIFY menuObjectPathChanged)

public:
    explicit CachedUnityMenuModel(QObject *parent = 0);
    CachedUnityMenuModel(UnityMenuModel* model);
    ~CachedUnityMenuModel();

    UnityMenuModel* model() const;

    QString busName() const;
    void setBusName(const QString &name);

    QVariantMap actions() const;
    void setActions(const QVariantMap &actions);

    QString menuObjectPath() const;
    void setMenuObjectPath(const QString &path);

Q_SIGNALS:
    void modelChanged(UnityMenuModel* model);
    void busNameChanged(const QString& busName);
    void actionsChanged(const QVariantMap& action);
    void menuObjectPathChanged(const QString& menuObjectPath);

private:
    UnityMenuModel* m_model;
    QString m_busName;
    QVariantMap m_actions;
    QString m_menuObjectPath;
};

#endif // CACHEDUNITYMENUMODEL_H
