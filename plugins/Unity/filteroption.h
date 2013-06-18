/*
 * Copyright (C) 2011 Canonical, Ltd.
 *
 * Authors:
 *  Florian Boucault <florian.boucault@canonical.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef FILTEROPTION_H
#define FILTEROPTION_H

// Local
#include "listmodelwrapper.h"

// Qt
#include <QObject>
#include <QMetaType>

// libunity-core
#include <UnityCore/Filter.h>

class FilterOption : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString id READ id NOTIFY idChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(QString iconHint READ iconHint NOTIFY iconHintChanged)
    Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged)

public:
    explicit FilterOption(unity::dash::FilterOption::Ptr unityFilterOption, QObject *parent = 0);

    /* getters */
    QString id() const;
    QString name() const;
    QString iconHint() const;
    bool active() const;

    /* setters */
    void setActive(bool active);

Q_SIGNALS:
    void idChanged(std::string);
    void nameChanged(std::string);
    void iconHintChanged(std::string);
    void activeChanged(bool);

private:
    void setUnityFilterOption(unity::dash::FilterOption::Ptr unityFilterOption);

    unity::dash::FilterOption::Ptr m_unityFilterOption;
};

Q_DECLARE_METATYPE(FilterOption*)

typedef ListModelWrapper<FilterOption, unity::dash::FilterOption::Ptr> FilterOptions;
Q_DECLARE_METATYPE(FilterOptions*)

#endif // FILTEROPTION_H
