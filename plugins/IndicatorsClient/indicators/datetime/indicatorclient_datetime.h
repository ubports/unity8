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
 *      Ubo Riboni <ugo.riboni@canonical.com>
 */

#ifndef INDICATORCLIENT_DATETIME_H
#define INDICATORCLIENT_DATETIME_H

#include "indicatorclient_common.h"
#include <QTimer>
#include <QDateTime>

class QStateAction;

class IndicatorClientDateTime : public IndicatorClientCommon
{
    Q_OBJECT
public:
    IndicatorClientDateTime(QObject *parent=0);
    ~IndicatorClientDateTime();

    void init(const QSettings& settings);
    void shutdown();
    QString dateTime() const;
    bool parseRootElement(const QString &type, QMap<int, QVariant> data);
    QQmlComponent *createComponent(QQmlEngine *engine, QObject *parent=0) const;

private Q_SLOTS:
    void onTimeout();
    void updateTimeFormat(const QVariant &state);

private:
    QTimer m_timer;
    QString m_format;
    QStateAction *m_action;
};

#endif
