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
 *
 */

#ifndef SHAREDLOMIRIMENUMODEL_H
#define SHAREDLOMIRIMENUMODEL_H

#include "lomiriindicatorsglobal.h"

#include <QObject>
#include <QSharedPointer>
#include <QVariantMap>

class LomiriMenuModel;

class LOMIRIINDICATORS_EXPORT SharedLomiriMenuModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QByteArray busName READ busName WRITE setBusName NOTIFY busNameChanged)
    Q_PROPERTY(QByteArray menuObjectPath READ menuObjectPath WRITE setMenuObjectPath NOTIFY menuObjectPathChanged)
    Q_PROPERTY(QVariantMap actions READ actions WRITE setActions NOTIFY actionsChanged)
    Q_PROPERTY(LomiriMenuModel* model READ model NOTIFY modelChanged)

public:
    SharedLomiriMenuModel(QObject* parent = nullptr);

    QByteArray busName() const;
    void setBusName(const QByteArray&);

    QByteArray menuObjectPath() const;
    void setMenuObjectPath(const QByteArray&);

    QVariantMap actions() const;
    void setActions(const QVariantMap&);

    LomiriMenuModel* model() const;

Q_SIGNALS:
    void busNameChanged();
    void menuObjectPathChanged();
    void actionsChanged();
    void modelChanged();

private:
    void initialize();

    QByteArray m_busName;
    QByteArray m_menuObjectPath;
    QVariantMap m_actions;
    QSharedPointer<LomiriMenuModel> m_model;
};

#endif // SHAREDLOMIRIMENUMODEL_H
