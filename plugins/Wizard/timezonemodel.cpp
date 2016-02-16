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

static QByteArrayList olsenTimezones = {
    "Africa/Abidjan",
    "Africa/Accra",
    "Africa/Addis_Ababa",
    "Africa/Algiers",
    "Africa/Asmara",
    "Africa/Bamako",
    "Africa/Bangui",
    "Africa/Banjul",
    "Africa/Bissau",
    "Africa/Blantyre",
    "Africa/Brazzaville",
    "Africa/Bujumbura",
    "Africa/Cairo",
    "Africa/Casablanca",
    "Africa/Conakry",
    "Africa/Dakar",
    "Africa/Dar_es_Salaam",
    "Africa/Djibouti",
    "Africa/Douala",
    "Africa/El_Aaiun",
    "Africa/Freetown",
    "Africa/Gaborone",
    "Africa/Harare",
    "Africa/Johannesburg",
    "Africa/Kampala",
    "Africa/Khartoum",
    "Africa/Kigali",
    "Africa/Kinshasa",
    "Africa/Lagos",
    "Africa/Libreville",
    "Africa/Lome",
    "Africa/Luanda",
    "Africa/Lubumbashi",
    "Africa/Lusaka",
    "Africa/Malabo",
    "Africa/Maputo",
    "Africa/Maseru",
    "Africa/Mbabane",
    "Africa/Mogadishu",
    "Africa/Monrovia",
    "Africa/Nairobi",
    "Africa/Ndjamena",
    "Africa/Niamey",
    "Africa/Nouakchott",
    "Africa/Ouagadougou",
    "Africa/Porto-Novo",
    "Africa/Sao_Tome",
    "Africa/Tripoli",
    "Africa/Tunis",
    "Africa/Windhoek",
    "America/Adak",
    "America/Anguilla",
    "America/Antigua",
    "America/Araguaina",
    "America/Argentina/Buenos_Aires",
    "America/Argentina/Catamarca",
    "America/Argentina/Cordoba",
    "America/Argentina/Jujuy",
    "America/Argentina/La_Rioja",
    "America/Argentina/Mendoza",
    "America/Argentina/Rio_Gallegos",
    "America/Argentina/San_Juan",
    "America/Argentina/San_Luis",
    "America/Argentina/Tucuman",
    "America/Argentina/Ushuaia",
    "America/Aruba",
    "America/Asuncion",
    "America/Atikokan",
    "America/Bahia",
    "America/Barbados",
    "America/Belem",
    "America/Belize",
    "America/Blanc-Sablon",
    "America/Boa_Vista",
    "America/Bogota",
    "America/Boise",
    "America/Cambridge_Bay",
    "America/Campo_Grande",
    "America/Cancun",
    "America/Caracas",
    "America/Cayenne",
    "America/Cayman",
    "America/Chicago",
    "America/Chihuahua",
    "America/Coral_Harbour",
    "America/Costa_Rica",
    "America/Cuiaba",
    "America/Curacao",
    "America/Dawson",
    "America/Dawson_Creek",
    "America/Denver",
    "America/Dominica",
    "America/Edmonton",
    "America/Eirunepe",
    "America/El_Salvador",
    "America/Fortaleza",
    "America/Glace_Bay",
    "America/Goose_Bay",
    "America/Grand_Turk",
    "America/Grenada",
    "America/Guadeloupe",
    "America/Guatemala",
    "America/Guayaquil",
    "America/Guyana",
    "America/Halifax",
    "America/Havana",
    "America/Hermosillo",
    "America/Indiana/Indianapolis",
    "America/Indiana/Knox",
    "America/Indiana/Marengo",
    "America/Indiana/Petersburg",
    "America/Indiana/Vevay",
    "America/Indiana/Vincennes",
    "America/Indiana/Winamac",
    "America/Inuvik",
    "America/Iqaluit",
    "America/Jamaica",
    "America/Juneau",
    "America/Kentucky/Louisville",
    "America/Kentucky/Monticello",
    "America/La_Paz",
    "America/Lima",
    "America/Los_Angeles",
    "America/Maceio",
    "America/Managua",
    "America/Manaus",
    "America/Marigot",
    "America/Martinique",
    "America/Mazatlan",
    "America/Menominee",
    "America/Merida",
    "America/Mexico_City",
    "America/Miquelon",
    "America/Moncton",
    "America/Monterrey",
    "America/Montevideo",
    "America/Montreal",
    "America/Montserrat",
    "America/Nassau",
    "America/New_York",
    "America/Nipigon",
    "America/Noronha",
    "America/North_Dakota/Center",
    "America/North_Dakota/Salem",
    "America/Panama",
    "America/Pangnirtung",
    "America/Paramaribo",
    "America/Phoenix",
    "America/Port-au-Prince",
    "America/Port_of_Spain",
    "America/Porto_Velho",
    "America/Puerto_Rico",
    "America/Rainy_River",
    "America/Rankin_Inlet",
    "America/Recife",
    "America/Regina",
    "America/Resolute",
    "America/Rio_Branco",
    "America/Santarem",
    "America/Santiago",
    "America/Santo_Domingo",
    "America/Sao_Paulo",
    "America/St_Barthelemy",
    "America/St_Johns",
    "America/St_Kitts",
    "America/St_Lucia",
    "America/St_Thomas",
    "America/St_Vincent",
    "America/Tegucigalpa",
    "America/Thunder_Bay",
    "America/Tijuana",
    "America/Toronto",
    "America/Tortola",
    "America/Vancouver",
    "America/Whitehorse",
    "America/Winnipeg",
    "America/Yellowknife",
    "America/Swift_Current",
    "Arctic/Longyearbyen",
    "Asia/Aden",
    "Asia/Almaty",
    "Asia/Amman",
    "Asia/Anadyr",
    "Asia/Aqtau",
    "Asia/Aqtobe",
    "Asia/Ashgabat",
    "Asia/Baghdad",
    "Asia/Bahrain",
    "Asia/Baku",
    "Asia/Bangkok",
    "Asia/Beirut",
    "Asia/Bishkek",
    "Asia/Brunei",
    "Asia/Choibalsan",
    "Asia/Chongqing",
    "Asia/Colombo",
    "Asia/Damascus",
    "Asia/Dhaka",
    "Asia/Dili",
    "Asia/Dubai",
    "Asia/Dushanbe",
    "Asia/Gaza",
    "Asia/Harbin",
    "Asia/Ho_Chi_Minh",
    "Asia/Hong_Kong",
    "Asia/Hovd",
    "Asia/Irkutsk",
    "Asia/Jakarta",
    "Asia/Jayapura",
    "Asia/Jerusalem",
    "Asia/Kabul",
    "Asia/Kamchatka",
    "Asia/Karachi",
    "Asia/Kashgar",
    "Asia/Katmandu",
    "Asia/Kolkata",
    "Asia/Krasnoyarsk",
    "Asia/Kuala_Lumpur",
    "Asia/Kuching",
    "Asia/Kuwait",
    "Asia/Macau",
    "Asia/Magadan",
    "Asia/Makassar",
    "Asia/Manila",
    "Asia/Muscat",
    "Asia/Nicosia",
    "Asia/Novosibirsk",
    "Asia/Omsk",
    "Asia/Oral",
    "Asia/Phnom_Penh",
    "Asia/Pontianak",
    "Asia/Pyongyang",
    "Asia/Qatar",
    "Asia/Qyzylorda",
    "Asia/Rangoon",
    "Asia/Riyadh",
    "Asia/Sakhalin",
    "Asia/Samarkand",
    "Asia/Seoul",
    "Asia/Shanghai",
    "Asia/Singapore",
    "Asia/Taipei",
    "Asia/Tashkent",
    "Asia/Tbilisi",
    "Asia/Tehran",
    "Asia/Thimphu",
    "Asia/Tokyo",
    "Asia/Ulaanbaatar",
    "Asia/Urumqi",
    "Asia/Vientiane",
    "Asia/Vladivostok",
    "Asia/Yakutsk",
    "Asia/Yekaterinburg",
    "Asia/Yerevan",
    "Atlantic/Azores",
    "Atlantic/Bermuda",
    "Atlantic/Canary",
    "Atlantic/Cape_Verde",
    "Atlantic/Faroe",
    "Atlantic/Madeira",
    "Atlantic/Reykjavik",
    "Atlantic/South_Georgia",
    "Atlantic/St_Helena",
    "Atlantic/Stanley",
    "Australia/Adelaide",
    "Australia/Brisbane",
    "Australia/Broken_Hill",
    "Australia/Currie",
    "Australia/Darwin",
    "Australia/Eucla",
    "Australia/Hobart",
    "Australia/Lindeman",
    "Australia/Lord_Howe",
    "Australia/Melbourne",
    "Australia/Perth",
    "Australia/Sydney",
    "Europe/Amsterdam",
    "Europe/Andorra",
    "Europe/Athens",
    "Europe/Belgrade",
    "Europe/Berlin",
    "Europe/Bratislava",
    "Europe/Brussels",
    "Europe/Bucharest",
    "Europe/Budapest",
    "Europe/Chisinau",
    "Europe/Copenhagen",
    "Europe/Dublin",
    "Europe/Gibraltar",
    "Europe/Guernsey",
    "Europe/Helsinki",
    "Europe/Isle_of_Man",
    "Europe/Istanbul",
    "Europe/Jersey",
    "Europe/Kaliningrad",
    "Europe/Kiev",
    "Europe/Lisbon",
    "Europe/Ljubljana",
    "Europe/London",
    "Europe/Luxembourg",
    "Europe/Madrid",
    "Europe/Malta",
    "Europe/Marienhamn",
    "Europe/Minsk",
    "Europe/Monaco",
    "Europe/Moscow",
    "Europe/Oslo",
    "Europe/Paris",
    "Europe/Podgorica",
    "Europe/Prague",
    "Europe/Riga",
    "Europe/Rome",
    "Europe/Samara",
    "Europe/San_Marino",
    "Europe/Sarajevo",
    "Europe/Simferopol",
    "Europe/Skopje",
    "Europe/Sofia",
    "Europe/Stockholm",
    "Europe/Tallinn",
    "Europe/Tirane",
    "Europe/Uzhgorod",
    "Europe/Vaduz",
    "Europe/Vatican",
    "Europe/Vienna",
    "Europe/Vilnius",
    "Europe/Volgograd",
    "Europe/Warsaw",
    "Europe/Zagreb",
    "Europe/Zaporozhye",
    "Europe/Zurich",
    "Indian/Antananarivo",
    "Indian/Chagos",
    "Indian/Christmas",
    "Indian/Cocos",
    "Indian/Comoro",
    "Indian/Kerguelen",
    "Indian/Mahe",
    "Indian/Maldives",
    "Indian/Mauritius",
    "Indian/Mayotte",
    "Indian/Reunion",
    "Pacific/Apia",
    "Pacific/Auckland",
    "Pacific/Chatham",
    "Pacific/Easter",
    "Pacific/Efate",
    "Pacific/Enderbury",
    "Pacific/Fakaofo",
    "Pacific/Fiji",
    "Pacific/Funafuti",
    "Pacific/Galapagos",
    "Pacific/Gambier",
    "Pacific/Guadalcanal",
    "Pacific/Guam",
    "Pacific/Honolulu",
    "Pacific/Johnston",
    "Pacific/Kiritimati",
    "Pacific/Kosrae",
    "Pacific/Kwajalein",
    "Pacific/Majuro",
    "Pacific/Marquesas",
    "Pacific/Midway",
    "Pacific/Nauru",
    "Pacific/Niue",
    "Pacific/Norfolk",
    "Pacific/Noumea",
    "Pacific/Pago_Pago",
    "Pacific/Palau",
    "Pacific/Pitcairn",
    "Pacific/Ponape",
    "Pacific/Port_Moresby",
    "Pacific/Rarotonga",
    "Pacific/Saipan",
    "Pacific/Tahiti",
    "Pacific/Tarawa",
    "Pacific/Tongatapu",
    "Pacific/Truk",
    "Pacific/Wake",
    "Pacific/Wallis",
    "America/Godthab"
};

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

    // olsen color map
    m_olsenMap.load(":/olsen_map.png");
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

QJsonArray TimeZoneLocationModel::timezoneAndOffsetAtMapPoint(int x, int y, const QSize &mapImageSize) const
{
    const QImage olsenMap = m_olsenMap.scaled(mapImageSize);
    qDebug() << "Clicked at" << x << y << "(" << olsenMap.width() << olsenMap.height() << ")";
    if (!olsenMap.valid(x,y)) {
        qWarning() << Q_FUNC_INFO << "Invalid pixel position:" << x << y;
        return QJsonArray();
    }

    const QRgb rgb = olsenMap.pixel(x,y);
    const int red = qRed(rgb);
    const int green = qGreen(rgb);
    qDebug() << "Red:" << red << ", green:" << green;
    if (red == 0 && green == 0) {
        qWarning() << "Clicked the water!";
        return QJsonArray();
    }

    const int zoneIndex = ((red & 248) << 1) + ((green >> 4) & 15);
    qDebug() << "Zone index:" << zoneIndex;
    if (zoneIndex >= 0 && zoneIndex < olsenTimezones.count()) {
        const QByteArray tzId = olsenTimezones.at(zoneIndex);
        qDebug() << "!!! Got TZ ID" << tzId;
        QTimeZone tz(tzId);
        if (tz.isValid()) {
            QJsonArray result;
            result.append(qUtf8Printable(tzId));
            result.append(static_cast<double>(tz.standardTimeOffset(QDateTime::currentDateTime())) / 3600);
            return result;
        }
        qWarning() << Q_FUNC_INFO << "Invalid timezone" << tzId;
        return QJsonArray();
    }

    qWarning() << Q_FUNC_INFO << "Invalid timezone index" << zoneIndex;
    return QJsonArray();
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
