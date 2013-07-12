/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
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

#ifndef ABSTRACTFILTEROPTION_H
#define ABSTRACTFILTEROPTION_H

// Qt
#include <QObject>
#include <QMetaType>

class AbstractFilterOption : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString id READ id NOTIFY idChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(QString iconHint READ iconHint NOTIFY iconHintChanged)
    Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged)

public:
    AbstractFilterOption(QObject *parent);

    /* getters */
    virtual QString id() const = 0;
    virtual QString name() const = 0;
    virtual QString iconHint() const = 0;
    virtual bool active() const = 0;

    /* setters */
    virtual void setActive(bool active) = 0;

Q_SIGNALS:
    void idChanged(const QString &);
    void nameChanged(const QString &);
    void iconHintChanged(const QString &);
    void activeChanged(bool);
};

Q_DECLARE_METATYPE(AbstractFilterOption*)

#endif // ABSTRACTFILTEROPTION_H
