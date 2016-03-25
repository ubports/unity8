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

#ifndef LOCALE_PLUGIN_H
#define LOCALE_PLUGIN_H

#include <QObject>
#include <QString>
#include <QJsonObject>
#include <QtQml>

class LocaleAttached: public QObject
{
    Q_OBJECT
protected:
    explicit LocaleAttached(QObject *parent = 0);

public:
    Q_INVOKABLE QString mccToCountryCode(int mcc) const;

    friend class LocalePlugin;
};

/**
 * A simplified wrapper around QLocale.
 *
 * The wrapper is implemented as an attached property, which makes it possible
 * to use it as if its methods were static:
 *
 * @code
 * var langs = LocalePlugin.languages();
 * @endcode
 */
class LocalePlugin: public QObject
{
    Q_OBJECT
public:
    explicit LocalePlugin(QObject *parent = 0);

    static LocaleAttached* qmlAttachedProperties(QObject *parent);
};

QML_DECLARE_TYPEINFO(LocalePlugin, QML_HAS_ATTACHED_PROPERTIES)

#endif // LOCALE_PLUGIN_H
