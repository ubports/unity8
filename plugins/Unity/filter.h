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

#ifndef FILTER_H
#define FILTER_H

// Qt
#include <QObject>
#include <QMetaType>

// libunity-core
#include <UnityCore/Filter.h>

class Filter : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString id READ id NOTIFY idChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(QString iconHint READ iconHint NOTIFY iconHintChanged)
    Q_PROPERTY(QString rendererName READ rendererName NOTIFY rendererNameChanged)
    Q_PROPERTY(bool visible READ visible NOTIFY visibleChanged)
    Q_PROPERTY(bool collapsed READ collapsed NOTIFY collapsedChanged)
    Q_PROPERTY(bool filtering READ filtering NOTIFY filteringChanged)

public:
    explicit Filter(QObject *parent = 0);

    /* getters */
    QString id() const;
    QString name() const;
    QString iconHint() const;
    QString rendererName() const;
    bool visible() const;
    bool collapsed() const;
    bool filtering() const;

    Q_INVOKABLE void clear();

    static Filter* newFromUnityFilter(unity::dash::Filter::Ptr unityFilter);
    bool hasUnityFilter(unity::dash::Filter::Ptr unityFilter) const;

Q_SIGNALS:
    void idChanged(std::string);
    void nameChanged(std::string);
    void iconHintChanged(std::string);
    void rendererNameChanged(std::string);
    void visibleChanged(bool);
    void collapsedChanged(bool);
    void filteringChanged(bool);

    void removed();

protected:
    unity::dash::Filter::Ptr m_unityFilter;
    virtual void setUnityFilter(unity::dash::Filter::Ptr unityFilter);
};

Q_DECLARE_METATYPE(Filter*)

#endif // FILTER_H
