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

#include "indicatorclient_datetime.h"

#include <qdbusmenumodel.h>
#include <qdbusactiongroup.h>
#include <qstateaction.h>
#include <QDateTime>
#include <QDebug>

IndicatorClientDateTime::IndicatorClientDateTime(QObject *parent)
    : IndicatorClientCommon(parent),
      m_action(0)
{
    setTitle("Date and Time");
    setPriority(IndicatorPriority::DATETIME);

    connect(&m_timer, SIGNAL(timeout()), SLOT(onTimeout()));
}

IndicatorClientDateTime::~IndicatorClientDateTime()
{
    if (m_action) {
        delete m_action;
    }
}

void IndicatorClientDateTime::init(const QSettings& settings)
{
    IndicatorClientCommon::init(settings);

    m_timer.start(1000 * 10);
}

void IndicatorClientDateTime::shutdown()
{
    m_timer.stop();
}


QString IndicatorClientDateTime::dateTime() const
{
    static char timestr[255];
    time_t t;
    struct tm *tmp;

    t = time(NULL);
    tmp = localtime(&t);
    if (tmp == 0) {
        return "";
    }

    int size = strftime(timestr, 255, m_format.toUtf8().data(), tmp);
    if (size == 0) {
        return "";
    }

    return QString::fromLatin1(timestr, size);
}

bool IndicatorClientDateTime::parseRootElement(const QString &type, QMap<int, QVariant> data)
{
    if (type == "com.canonical.indicator.root.time") {
        if (m_action != 0) {
            delete m_action;
        }

        QVariant action = data[QDBusMenuModel::Action];
        m_action = actionGroup()->action(action.toString());
        if (m_action->isValid()) {
            updateTimeFormat(m_action->state());
        }
        QObject::connect(m_action, SIGNAL(stateChanged(QVariant)), this, SLOT(updateTimeFormat(QVariant)));
        return true;
    } else {
        return false;
    }
}

void IndicatorClientDateTime::updateTimeFormat(const QVariant &state)
{
    if (state.isValid()) {
        // (sssb) : time format, icon, accessible name format, visible
        QVariantList states = state.toList();
        if (states.size() == 4) {
            m_format = states[0].toString();
            setIcon(QUrl(states[1].toString()));
            setVisible(states[2].toBool());
            onTimeout();
        }
    }
}

QUrl IndicatorClientDateTime::componentSource() const
{
    return QUrl("qrc:/indicatorsclient/qml/DatetimeIndicator.qml");
}

void IndicatorClientDateTime::onTimeout()
{
    QString newValue = dateTime();
    setLabel(newValue);
}
