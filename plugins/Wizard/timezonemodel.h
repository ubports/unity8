/*
 * Copyright (C) 2016 Canonical Ltd.
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

#include <geonames.h>
#include <glib.h>
#include <QAbstractListModel>

class TimeZoneLocationModel: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(bool listUpdating READ listUpdating NOTIFY listUpdatingChanged)
    Q_PROPERTY(QString filter READ filter WRITE setFilter NOTIFY filterChanged)
    Q_PROPERTY(QString country READ country WRITE setCountry NOTIFY countryChanged)
    Q_ENUMS(Roles)

public:
    explicit TimeZoneLocationModel(QObject *parent = nullptr);
    ~TimeZoneLocationModel();

    enum Roles {
        TimeZoneRole = Qt::UserRole + 1,
        CityRole,
        CountryRole,
        SimpleRole,
        OffsetRole,
        LatitudeRole,
        LongitudeRole
    };

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    bool listUpdating() const;

    QString filter() const;
    void setFilter(const QString &filter);

    QString country() const;
    void setCountry(const QString &country);

Q_SIGNALS:
    void listUpdatingChanged();
    void filterChanged();
    void countryChanged(const QString &country);

private:
    void setModel(const QList<GeonamesCity *> &locations);
    void setListUpdating(bool listUpdating);
    static void filterFinished(GObject      *source_object,
                               GAsyncResult *res,
                               gpointer      user_data);


    bool m_listUpdating;
    QString m_filter;
    QString m_country;
    GCancellable *m_cancellable;
    QHash<int, QByteArray> m_roleNames;
    QList<GeonamesCity *> m_locations;
    QList<GeonamesCity *> m_countryLocations;
};

#endif
