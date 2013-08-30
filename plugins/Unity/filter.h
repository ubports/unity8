/*
 * Copyright (C) 2011, 2013 Canonical, Ltd.
 *
 * Authors:
 *  Florian Boucault <florian.boucault@canonical.com>
 *  Pawel Stolowski <pawel.stolowski@canonical.com>
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

class GenericOptionsModel;

class Q_DECL_EXPORT Filter : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString id READ id CONSTANT)
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString iconHint READ iconHint CONSTANT)
    Q_PROPERTY(QString rendererName READ rendererName CONSTANT)
    Q_PROPERTY(bool visible READ visible CONSTANT)
    Q_PROPERTY(bool collapsed READ collapsed CONSTANT)
    Q_PROPERTY(bool filtering READ filtering CONSTANT)
    Q_PROPERTY(GenericOptionsModel* options READ options NOTIFY optionsChanged)

public:
    explicit Filter(QObject *parent = nullptr);

    /* getters */
    QString id() const;
    QString name() const;
    QString iconHint() const;
    QString rendererName() const;
    bool visible() const;
    bool collapsed() const;
    bool filtering() const;
    virtual GenericOptionsModel* options() const = 0;

    static Filter* newFromUnityFilter(unity::dash::Filter::Ptr unityFilter);
    bool hasUnityFilter(unity::dash::Filter::Ptr unityFilter) const;

public Q_SLOTS:
    void clear();

Q_SIGNALS:
    void optionsChanged();

protected:
    unity::dash::Filter::Ptr m_unityFilter;
    virtual void setUnityFilter(unity::dash::Filter::Ptr unityFilter);
};

Q_DECLARE_METATYPE(Filter*)

#endif // FILTER_H
