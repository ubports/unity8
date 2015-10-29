/*
 * Copyright (C) 2015 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef TIMEZONEMODEL_H
#define TIMEZONEMODEL_H

#include <QAbstractListModel>
#include <QSortFilterProxyModel>
#include <QThread>
#include <QtConcurrent>

class TimeZonePopulateWorker;

class TimeZoneLocationModel: public QAbstractListModel
{
    Q_OBJECT
    Q_ENUMS(Roles)
public:
    explicit TimeZoneLocationModel(QObject *parent = 0);
    ~TimeZoneLocationModel() = default;

    enum Roles {
        TimeZoneRole = Qt::UserRole + 1,
        CityRole,
        CountryRole,
        SimpleRole
    };

    struct TzLocation {
        bool operator<(const TzLocation &other) const
        {
            QString pattern("%1, %2");
            return pattern.arg(city).arg(country) <
                    pattern.arg(other.city).arg(other.country);
        }

        QString city;
        QString country;
        QString timezone;
        QString state;
        QString full_country;
    };

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

private Q_SLOTS:
    void processModelResult(const TzLocation &location);
    void store();

private:
    void init();
    QHash<int, QByteArray> m_roleNames;
    QList<TzLocation> m_locations;
    TimeZonePopulateWorker *m_workerThread;
};

Q_DECLARE_METATYPE (TimeZoneLocationModel::TzLocation)

class TimeZonePopulateWorker: public QThread
{
    Q_OBJECT
public:
    void run() override;

Q_SIGNALS:
    void resultReady(const TimeZoneLocationModel::TzLocation &tz);

private:
    void buildCityMap();
};

class TimeZoneFilterModel: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QString filter READ filter WRITE setFilter NOTIFY filterChanged)
    Q_PROPERTY(QString country READ country WRITE setCountry NOTIFY countryChanged)

public:
    explicit TimeZoneFilterModel(QObject *parent = 0);
    ~TimeZoneFilterModel() = default;
    bool filterAcceptsRow(int row, const QModelIndex &parentIndex) const override;

    QString filter() const;
    void setFilter(const QString &filter);

    QString country() const;
    void setCountry(const QString &country);

Q_SIGNALS:
    void filterChanged();
    void countryChanged(const QString &country);

private:
    QString m_filter;
    QStringMatcher m_stringMatcher;
    QString m_country;
};

#endif
