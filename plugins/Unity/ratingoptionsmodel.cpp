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

// self
#include "ratingoptionsmodel.h"

// local
#include "ratingfilteroption.h"

RatingOptionsModel::RatingOptionsModel(QObject *parent) :
    GenericOptionsModel(parent)
{
    for (int i=1; i<=5; i++) {
        auto opt = new RatingFilterOption(QString::number(i), i*0.2f, this);
        addOption(opt, i-1);
    }
}
