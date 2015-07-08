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

#include <QLocale>
#include <QStringList>

#include "LocalePlugin.h"

LocaleAttached::LocaleAttached(QObject* parent)
    : QObject(parent)
{
}

QJsonObject LocaleAttached::languages() const
{
    QJsonObject result;
    for (int i = QLocale::C + 1; i < QLocale::LastLanguage; ++i) {
        QLocale loc(static_cast<QLocale::Language>(i));
        result.insert(loc.name().split('_').first(), QLocale::languageToString(loc.language()));
    }

    return result;
}

QJsonObject LocaleAttached::countriesForLanguage(const QString &code) const
{
    QLocale tmp(code);
    const QList<QLocale> allLocales = QLocale::matchingLocales(tmp.language(), QLocale::AnyScript, QLocale::AnyCountry);
    QJsonObject result;
    Q_FOREACH(const QLocale &loc, allLocales) {
        const QString countryCode = loc.name().section('_', 1, 1);
        //qDebug() << "Matching country:" << countryCode;
        if (!countryCode.isEmpty()) {
            result.insert(countryCode, QLocale::countryToString(loc.country()));
        }
    }
    return result;
}

QJsonObject LocaleAttached::countries() const
{
    const QList<QLocale> allLocales = QLocale::matchingLocales(QLocale::AnyLanguage, QLocale::AnyScript, QLocale::AnyCountry);
    QJsonObject result;

    Q_FOREACH(const QLocale &loc, allLocales) {
        const QString countryCode = loc.name().section('_', 1, 1);
        if (countryCode.length() == 2) {
            result.insert(countryCode, QLocale::countryToString(loc.country()));
        }
    }

    return result;
}


LocalePlugin::LocalePlugin(QObject* parent)
    : QObject(parent)
{
}

LocaleAttached* LocalePlugin::qmlAttachedProperties(QObject* parent)
{
    return new LocaleAttached(parent);
}
