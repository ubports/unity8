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
 * Authors:
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

#ifndef FAKE_INDICATORSMODEL_H
#define FAKE_INDICATORSMODEL_H

#include <QAbstractListModel>

class FakeIndicatorsModel : public QAbstractListModel
{
    Q_OBJECT
    Q_ENUMS(Roles)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QString profile READ profile WRITE setProfile NOTIFY profileChanged)
public:

    FakeIndicatorsModel(QObject *parent=0);
    ~FakeIndicatorsModel();

    Q_INVOKABLE void load(const QString& profile);
    Q_INVOKABLE void unload();

    Q_INVOKABLE void append(const QVariantMap& row);

    Q_INVOKABLE QVariant data(int row, int role) const;

    QString profile() const;
    void setProfile(const QString& profile);

    /* QAbstractItemModel */
    QHash<int, QByteArray> roleNames() const;
    int columnCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    QModelIndex parent (const QModelIndex &index) const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const;

Q_SIGNALS:
    void countChanged();
    void profileChanged();

private:
    int count() const;

    typedef QHash<int, QVariant> Indicator;
    QList<Indicator*> m_indicators;
    QString m_profile;
};

#endif // FAKE_INDICATORSMODEL_H
