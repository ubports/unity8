/*
 * Copyright 2012 Canonical Ltd.
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
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

#ifndef INDICATORSMODEL_H
#define INDICATORSMODEL_H

#include "indicatorclientinterface.h"

#include <QAbstractListModel>
#include <QQmlEngine>

class WidgetsMap;
class IndicatorsManager;

class IndicatorsModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(WidgetsMap* widgetsMap READ widgetsMap NOTIFY widgetsMapChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum ModelRoles {
        Identifier = 0,
        Title,
        IconSource,
        Label,
        Description,
        QMLComponent,
        InitialProperties,
        IsValid
    };

    IndicatorsModel(QObject *parent=0);
    ~IndicatorsModel();

    WidgetsMap* widgetsMap() const;

    Q_INVOKABLE void load();
    Q_INVOKABLE void unload();

    Q_INVOKABLE QVariantMap get(int row) const;

    /* QAbstractItemModel */
    QHash<int, QByteArray> roleNames() const;
    int columnCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    QModelIndex parent (const QModelIndex &index) const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const;

Q_SIGNALS:
    void widgetsMapChanged(WidgetsMap *widgetsMap);
    void countChanged();

private Q_SLOTS:
    void onIdentifierChanged();
    void onIconChanged();
    void onTitleChanged();
    void onLabelChanged();
    void onIndicatorLoaded(const QString& indicator);
    void onIndicatorAboutToBeUnloaded(const QString& indicator);

private:
    IndicatorsManager *m_manager;
    WidgetsMap* m_widgetsMap;
    QList<IndicatorClientInterface::Ptr> m_plugins;

    void notifyDataChanged(QObject *sender, int role);
    int count() const;
};

#endif // INDICATORSMODEL_H
