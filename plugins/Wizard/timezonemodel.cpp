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
 *
 * Author: Lukáš Tinkl <lukas.tinkl@canonical.com>
 */

#include <QTimeZone>
#include <QDebug>

#include "timezonemodel.h"


TimeZoneModel::TimeZoneModel(QObject *parent)
    : QAbstractListModel(parent)
{
    init();
}

QString TimeZoneModel::selectedZoneId() const
{
    return m_selectedZoneId;
}

void TimeZoneModel::setSelectedZoneId(const QString &selectedZoneId)
{
    if (m_selectedZoneId == selectedZoneId)
        return;

    m_selectedZoneId = selectedZoneId;
    Q_EMIT selectedZoneIdChanged(selectedZoneId);
}

int TimeZoneModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_zoneIds.count();
}

QVariant TimeZoneModel::data(const QModelIndex &index, int role) const
{
    if (index.isValid()) {
        const QByteArray tzid = m_zoneIds.at(index.row());
        QTimeZone tz(tzid);

        if (!tz.isValid()) {
            qWarning() << Q_FUNC_INFO << "Invalid timezone" << tzid;
            return QVariant();
        }

        switch (role) {
        case IdRole:
            return tz.id();
        case Abbreviation:
            return tz.abbreviation(QDateTime::currentDateTime());
        case Country:
            return QLocale::countryToString(tz.country());
        case City: {
            const QString cityName = QString::fromUtf8(tzid.split('/').last());
            return cityName;
        }
        case Comment:
            return tz.comment();
        case Time:
            return QDateTime::currentDateTime().toTimeZone(tz).toString("h:mm");
        default:
            qWarning() << Q_FUNC_INFO << "Unsupported data role" << role;
            break;
        }
    }

    return QVariant();
}

QHash<int, QByteArray> TimeZoneModel::roleNames() const
{
    return {{IdRole, "id"}, {Abbreviation, "abbreviation"}, {Country, "country"}, {City, "city"}, {Comment, "comment"}, {Time, "time"}};
}

void TimeZoneModel::init()
{
    beginResetModel();
    m_zoneIds = QTimeZone::availableTimeZoneIds();
    endResetModel();
}


TimeZoneFilterModel::TimeZoneFilterModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    m_stringMatcher.setCaseSensitivity(Qt::CaseInsensitive);
}

bool TimeZoneFilterModel::filterAcceptsRow(int row, const QModelIndex &parentIndex) const
{
    if (!sourceModel() || m_filter.isEmpty()) {
        return true;
    }

    const QString city = sourceModel()->index(row, 0, parentIndex).data(TimeZoneModel::City).toString();
    const QString country = sourceModel()->index(row, 0, parentIndex).data(TimeZoneModel::Country).toString();

    if (m_stringMatcher.indexIn(city) != -1 || m_stringMatcher.indexIn(country) != -1) {
        return true;
    }

    return false;
}

QString TimeZoneFilterModel::filter() const
{
    return m_filter;
}

void TimeZoneFilterModel::setFilter(const QString &filter)
{
    m_filter = filter;
    m_stringMatcher.setPattern(m_filter);
    Q_EMIT filterChanged();
    invalidate();
}
