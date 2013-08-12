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

#ifndef RATINGFILTEROPTION_H
#define RATINGFILTEROPTION_H

#include "abstractfilteroption.h"

class Q_DECL_EXPORT RatingFilterOption : public AbstractFilterOption
{
    Q_OBJECT

public:
    explicit RatingFilterOption(const QString &id, float ratingValue, QObject *parent = nullptr);

    /* getters */
    QString id() const override;
    QString name() const override;
    QString iconHint() const override;
    bool active() const override;
    float value() const;

    /* setters */
    void setActive(bool active) override;

private:
    bool m_active;
    QString m_id;
    float m_value;
};

Q_DECLARE_METATYPE(RatingFilterOption*)

#endif // RATINGFILTEROPTION_H
