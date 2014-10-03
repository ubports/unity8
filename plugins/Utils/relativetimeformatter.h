/*
 * Copyright 2014 Canonical Ltd.
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
 *
 */

#ifndef RELATIVETIMEFORMATTER_H
#define RELATIVETIMEFORMATTER_H

#include "timeformatter.h"

// TODO - move this to the sdk
// https://blueprints.launchpad.net/ubuntu-ui-toolkit/+spec/time-formatter
class RelativeTimeFormatter : public GDateTimeFormatter
{
    Q_OBJECT
public:
    RelativeTimeFormatter(QObject *parent = 0);

    QString format() const override;
};

#endif // RELATIVETIMEFORMATTER_H
