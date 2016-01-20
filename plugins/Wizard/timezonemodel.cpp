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

#include <QDebug>

#include <glib.h>
#include <glib-object.h>
#include <timezonemap/tz.h>

#include "LocalePlugin.h"
#include "timezonemodel.h"


TimeZoneLocationModel::TimeZoneLocationModel(QObject *parent):
    QAbstractListModel(parent),
    m_workerThread(new TimeZonePopulateWorker())
{
    qRegisterMetaType<TzLocationWizard>();

    m_roleNames[Qt::DisplayRole] = "displayName";
    m_roleNames[TimeZoneRole] = "timeZone";
    m_roleNames[CityRole] = "city";
    m_roleNames[CountryRole] = "country";
    m_roleNames[OffsetRole] = "offset";
    m_roleNames[LatitudeRole] = "latitude";
    m_roleNames[LongitudeRole] = "longitude";

    QObject::connect(m_workerThread,
                     &TimeZonePopulateWorker::resultReady,
                     this,
                     &TimeZoneLocationModel::processModelResult);
    QObject::connect(m_workerThread,
                     &TimeZonePopulateWorker::finished,
                     this,
                     &TimeZoneLocationModel::store);
    QObject::connect(m_workerThread,
                     &TimeZonePopulateWorker::finished,
                     m_workerThread,
                     &QObject::deleteLater);

    init();
}

void TimeZoneLocationModel::init()
{
    beginResetModel();
    m_workerThread->start();
}

void TimeZoneLocationModel::store()
{
    m_workerThread = nullptr;
    endResetModel();
}

void TimeZoneLocationModel::processModelResult(const TzLocationWizard &location)
{
    m_locations.append(location);
}

int TimeZoneLocationModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_locations.count();
}

QVariant TimeZoneLocationModel::data(const QModelIndex &index, int role) const
{
    if (index.row() >= m_locations.count() || index.row() < 0)
        return QVariant();

    const TzLocationWizard tz = m_locations.at(index.row());

    const QString country(tz.full_country.isEmpty() ? tz.country : tz.full_country);

    switch (role) {
    case Qt::DisplayRole:
        if (!tz.state.isEmpty())
            return QStringLiteral("%1, %2, %3").arg(tz.city).arg(tz.state).arg(country);
        else
            return QStringLiteral("%1, %2").arg(tz.city).arg(country);
    case SimpleRole:
        return QStringLiteral("%1, %2").arg(tz.city).arg(country);
    case TimeZoneRole:
        return tz.timezone;
    case CountryRole:
        return tz.country;
    case CityRole:
        return tz.city;
    case OffsetRole: {
        QTimeZone tmp(tz.timezone.toLatin1());
        return static_cast<double>(tmp.standardTimeOffset(QDateTime::currentDateTime())) / 3600;
    }
    case LatitudeRole:
        return tz.latitude;
    case LongitudeRole:
        return tz.longitude;
    default:
        qWarning() << Q_FUNC_INFO << "Unknown role";
        return QVariant();
    }
}

QHash<int, QByteArray> TimeZoneLocationModel::roleNames() const
{
    return m_roleNames;
}

void TimeZonePopulateWorker::run()
{
    buildCityMap();
}

void TimeZonePopulateWorker::buildCityMap()
{
    TzDB *tzdb = tz_load_db();
    GPtrArray *tz_locations = tz_get_locations(tzdb);

    TimeZoneLocationModel::TzLocationWizard tmpTz;

    for (guint i = 0; i < tz_locations->len; ++i) {
        auto tmp = static_cast<CcTimezoneLocation *>(g_ptr_array_index(tz_locations, i));
        gchar *en_name, *country, *zone, *state, *full_country;
        gdouble latitude;
        gdouble longitude;
        g_object_get (tmp, "en_name", &en_name,
                      "country", &country,
                      "zone", &zone,
                      "state", &state,
                      "full_country", &full_country,
                      "latitude", &latitude,
                      "longitude", &longitude,
                      nullptr);
        // There are empty entries in the DB
        if (g_strcmp0(en_name, "") != 0) {
            tmpTz.city = en_name;
            tmpTz.country = country;
            tmpTz.timezone = zone;
            tmpTz.state = state;
            tmpTz.full_country = full_country;
            tmpTz.latitude = latitude;
            tmpTz.longitude = longitude;

            Q_EMIT (resultReady(tmpTz));
        }
        g_free (en_name);
        g_free (country);
        g_free (zone);
        g_free (state);
        g_free (full_country);
    }

    g_ptr_array_free (tz_locations, TRUE);
    tz_db_free(tzdb);
}


TimeZoneFilterModel::TimeZoneFilterModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    setDynamicSortFilter(false);
    setSortLocaleAware(true);
    setSortRole(TimeZoneLocationModel::CityRole);
    m_stringMatcher.setCaseSensitivity(Qt::CaseInsensitive);
    sort(0);
}

bool TimeZoneFilterModel::filterAcceptsRow(int row, const QModelIndex &parentIndex) const
{
    if (!sourceModel()) {
        return true;
    }

    if (!m_filter.isEmpty()) { // filtering by freeform text input, cf setFilter(QString)
        const QString city = sourceModel()->index(row, 0, parentIndex).data(TimeZoneLocationModel::CityRole).toString();

        if (m_stringMatcher.indexIn(city) == 0) { // match at the beginning of the city name
            return true;
        }
    } else if (!m_country.isEmpty()) { // filter by country code
        const QString countryCode = sourceModel()->index(row, 0, parentIndex).data(TimeZoneLocationModel::CountryRole).toString();
        return m_country.compare(countryCode, Qt::CaseInsensitive) == 0;
    }

    return false;
}

QString TimeZoneFilterModel::filter() const
{
    return m_filter;
}

void TimeZoneFilterModel::setFilter(const QString &filter)
{
    if (filter != m_filter) {
        m_filter = filter;
        m_stringMatcher.setPattern(m_filter);
        Q_EMIT filterChanged();
        invalidate();
    }
}

QString TimeZoneFilterModel::country() const
{
    return m_country;
}

void TimeZoneFilterModel::setCountry(const QString &country)
{
    if (m_country == country)
        return;

    m_country = country;
    Q_EMIT countryChanged(country);
}
