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

#include "indicator.h"

#include <QAbstractListModel>
#include <QQmlEngine>

class IndicatorsManager;

class IndicatorsModel : public QAbstractListModel
{
    Q_OBJECT
    Q_ENUMS(Roles)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QVariant indicatorData READ indicatorData WRITE setIndicatorData NOTIFY indicatorDataChanged)

public:

    IndicatorsModel(QObject *parent=0);
    ~IndicatorsModel();

    Q_INVOKABLE void load();
    Q_INVOKABLE void unload();

    Q_INVOKABLE QVariant data(int row, int role = Qt::DisplayRole) const;

    /* QAbstractItemModel */
    QHash<int, QByteArray> roleNames() const;
    int columnCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    QModelIndex parent (const QModelIndex &index) const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const;

    void setIndicatorData(const QVariant& data);
    QVariant indicatorData() const;

Q_SIGNALS:
    void countChanged();
    void indicatorDataChanged(const QVariant& data);

private Q_SLOTS:
    void onIdentifierChanged();
    void onIndicatorPropertiesChanged();
    void onIndicatorLoaded(const QString& indicator);
    void onIndicatorAboutToBeUnloaded(const QString& indicator);

private:
    IndicatorsManager *m_manager;

    QList<Indicator::Ptr> m_indicators;
    QVariant m_indicator_data;
    QMap<QString, QVariantMap> m_parsed_indicator_data;

    void notifyDataChanged(QObject *sender, int role);
    int count() const;
    QVariant indicatorData(const Indicator::Ptr& indicator, int role) const;
    static QVariant defaultData(Indicator::Ptr indicator, int role);
};

#endif // INDICATORSMODEL_H
