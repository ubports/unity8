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

#include <QDebug>

#include <glib.h>
#include <glib-object.h>

#include "LocalePlugin.h"
#include "timezonemodel.h"

TimeZoneLocationModel::TimeZoneLocationModel(QObject *parent):
    QAbstractListModel(parent),
    m_listUpdating(false),
    m_cancellable(nullptr)
{
    m_roleNames[Qt::DisplayRole] = "displayName";
    m_roleNames[TimeZoneRole] = "timeZone";
    m_roleNames[CityRole] = "city";
    m_roleNames[CountryRole] = "country";
    m_roleNames[OffsetRole] = "offset";
    m_roleNames[LatitudeRole] = "latitude";
    m_roleNames[LongitudeRole] = "longitude";
}

int TimeZoneLocationModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    } else if (m_filter.isEmpty()) {
        return m_countryLocations.count();
    } else {
        return m_locations.count();
    }
}

QVariant TimeZoneLocationModel::data(const QModelIndex &index, int role) const
{
    GeonamesCity *city;
    if (m_filter.isEmpty()) {
        city = m_countryLocations.value(index.row());
    } else {
        city = m_locations.value(index.row());
    }
    if (!city)
        return QVariant();

    switch (role) {
    case Qt::DisplayRole:
        return QStringLiteral("%1, %2, %3").arg(geonames_city_get_name(city))
                                           .arg(geonames_city_get_state(city))
                                           .arg(geonames_city_get_country(city));
    case SimpleRole:
        return QStringLiteral("%1, %2").arg(geonames_city_get_name(city))
                                       .arg(geonames_city_get_country(city));
    case TimeZoneRole:
        return geonames_city_get_timezone(city);
    case CountryRole:
        return geonames_city_get_country(city);
    case CityRole:
        return geonames_city_get_name(city);
    case OffsetRole: {
        QTimeZone tmp(geonames_city_get_timezone(city));
        return static_cast<double>(tmp.standardTimeOffset(QDateTime::currentDateTime())) / 3600;
    }
    case LatitudeRole:
        return geonames_city_get_latitude(city);
    case LongitudeRole:
        return geonames_city_get_longitude(city);
    default:
        qWarning() << Q_FUNC_INFO << "Unknown role";
        return QVariant();
    }
}

QHash<int, QByteArray> TimeZoneLocationModel::roleNames() const
{
    return m_roleNames;
}

void TimeZoneLocationModel::setModel(const QList<GeonamesCity *> &locations)
{
    beginResetModel();

    Q_FOREACH(GeonamesCity *city, m_locations) {
        geonames_city_free(city);
    }

    m_locations = locations;
    endResetModel();
}

void TimeZoneLocationModel::filterFinished(GObject      *source_object,
                                           GAsyncResult *res,
                                           gpointer      user_data)
{
    Q_UNUSED(source_object);

    g_autofree gint *cities = nullptr;
    guint cities_len = 0;
    g_autoptr(GError) error = nullptr;

    cities = geonames_query_cities_finish(res, &cities_len, &error);
    if (error) {
        if (!g_error_matches(error, G_IO_ERROR, G_IO_ERROR_CANCELLED)) {
            TimeZoneLocationModel *model = static_cast<TimeZoneLocationModel *>(user_data);
            g_clear_object(&model->m_cancellable);
            model->setListUpdating(false);
            qWarning() << "Could not filter timezones:" << error->message;
        }
        return;
    }

    QList<GeonamesCity *> locations;

    for (guint i = 0; i < cities_len; ++i) {
        GeonamesCity *city = geonames_get_city(cities[i]);
        if (city) {
            locations.append(city);
        }
    }

    TimeZoneLocationModel *model = static_cast<TimeZoneLocationModel *>(user_data);

    g_clear_object(&model->m_cancellable);

    model->setModel(locations);
    model->setListUpdating(false);
}

bool TimeZoneLocationModel::listUpdating() const
{
    return m_listUpdating;
}

void TimeZoneLocationModel::setListUpdating(bool listUpdating)
{
    if (m_listUpdating != listUpdating) {
        m_listUpdating = listUpdating;
        Q_EMIT listUpdatingChanged();
    }
}

QString TimeZoneLocationModel::filter() const
{
    return m_filter;
}

void TimeZoneLocationModel::setFilter(const QString &filter)
{
    if (filter != m_filter) {
        m_filter = filter;
        Q_EMIT filterChanged();
    }

    setListUpdating(true);

    if (m_cancellable) {
        g_cancellable_cancel(m_cancellable);
        g_clear_object(&m_cancellable);
    }

    setModel(QList<GeonamesCity *>());

    if (filter.isEmpty()) {
        setListUpdating(false);
        return;
    }

    m_cancellable = g_cancellable_new();
    geonames_query_cities(filter.toUtf8().data(),
                          GEONAMES_QUERY_DEFAULT,
                          m_cancellable,
                          filterFinished,
                          this);
}

QString TimeZoneLocationModel::country() const
{
    return m_country;
}

static bool citycmp(GeonamesCity *a, GeonamesCity *b)
{
    return geonames_city_get_population(b) < geonames_city_get_population(a);
}

void TimeZoneLocationModel::setCountry(const QString &country)
{
    if (m_country == country)
        return;

    beginResetModel();

    m_country = country;

    Q_FOREACH(GeonamesCity *city, m_countryLocations) {
        geonames_city_free(city);
    }
    m_countryLocations.clear();

    gint num_cities = geonames_get_n_cities();
    for (gint i = 0; i < num_cities; i++) {
        GeonamesCity *city = geonames_get_city(i);
        if (city && m_country == geonames_city_get_country_code(city)) {
            m_countryLocations.append(city);
        }
    }

    std::sort(m_countryLocations.begin(), m_countryLocations.end(), citycmp);

    endResetModel();

    Q_EMIT countryChanged(country);
}

TimeZoneLocationModel::~TimeZoneLocationModel()
{
    if (m_cancellable) {
        g_cancellable_cancel(m_cancellable);
        g_clear_object(&m_cancellable);
    }

    Q_FOREACH(GeonamesCity *city, m_countryLocations) {
        geonames_city_free(city);
    }

    Q_FOREACH(GeonamesCity *city, m_locations) {
        geonames_city_free(city);
    }
}
