/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 *      Olivier Tilloy <olivier.tilloy@canonical.com>
 */

#ifndef INDICATORCLIENT_MESSAGING_H
#define INDICATORCLIENT_MESSAGING_H

#include "indicatorclient_common.h"

class IndicatorClientMessaging : public IndicatorClientCommon
{
    Q_OBJECT
public:
    IndicatorClientMessaging(QObject *parent=0);
    ~IndicatorClientMessaging();

    void init(const QSettings& settings);
    QQmlComponent* createComponent(QQmlEngine *engine, QObject *parent) const;
    WidgetsMap widgets();
};

#endif
