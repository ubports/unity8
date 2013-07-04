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
 */

#ifndef FLATMENUPROXYMODEL_H
#define FLATMENUPROXYMODEL_H

#include <QAbstractProxyModel>
#include <qdbusmenumodel.h>

class SectionInfo;

class FlatMenuProxyModel : public QAbstractProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int busType READ busType WRITE setIntBusType NOTIFY busTypeChanged)
    Q_PROPERTY(QString busName READ busName WRITE setBusName NOTIFY busNameChanged)
    Q_PROPERTY(QString objectPath READ objectPath WRITE setObjectPath NOTIFY objectPathChanged)
    Q_PROPERTY(int status READ status NOTIFY statusChanged)

    Q_ENUMS(Roles)
public:
    FlatMenuProxyModel(QAbstractItemModel *source=0);
    ~FlatMenuProxyModel();

    void setSourceModel(QAbstractItemModel * sourceModel);

    Q_INVOKABLE QVariant data(int row, int role = Qt::DisplayRole) const;

    QModelIndex mapFromSource(const QModelIndex &index) const;
    QModelIndex mapToSource(const QModelIndex &index) const;

    QModelIndex index(int row, int column = 0, const QModelIndex &parent = QModelIndex()) const;
    QModelIndex parent(const QModelIndex &index) const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    int count() const;
    int columnCount(const QModelIndex &parent) const;

    void setBusName(const QString &busName);
    QString busName() const;

    void setObjectPath(const QString &busName);
    QString objectPath() const;

    DBusEnums::BusType busType() const;
    void setIntBusType(int type);

    int status() const;

public Q_SLOTS:
    void onModelAboutToBeReset();
    void onModelReset();

    void start();
    void stop();

Q_SIGNALS:
    void countChanged();

    void busTypeChanged();
    void busNameChanged();
    void objectPathChanged();
    void statusChanged();

private:
    QDBusMenuModel *m_model;
    mutable QMap<int, QString> m_indexCache;
    int m_rowCount;

    int rowOffsetOf(const QModelIndex &index, int row, bool inclusive = false) const;
    int recursiveRowCount(const QModelIndex &index) const;
    QModelIndex index(int row, int rowCount, const QModelIndex &parent, const QString &key) const;
};

#endif
