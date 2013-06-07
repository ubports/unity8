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
 */

#ifndef INDICATORCLIENT_NETWORK_H
#define INDICATORCLIENT_NETWORK_H

#include "indicatorclient_common.h"
#include <QTimer>

class QStateAction;

class IndicatorClientNetwork : public IndicatorClientCommon
{
    Q_OBJECT
public:
    IndicatorClientNetwork(QObject *parent=0);
    ~IndicatorClientNetwork();

    void init(const QSettings& settings);
    QUrl componentSource() const;
    bool parseRootElement(const QString &type, QMap<int, QVariant> data);

private Q_SLOTS:
    void animationNextFrame();
    void updateNetworkStatus(const QVariant &state);

private:
    QStateAction *m_action;
    QTimer m_timedAnimation;

    QString getIconBasedOnSingal(uint signal) const;
};

#endif
