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
 *     Alberto Ruiz <alberto.ruiz@canonical.com>
 *     Renato Araujo Oliveira Filho <renato@canonical.com>
 */

#ifndef NETWORKAGENT_H
#define NETWORKAGENT_H

#include "secret-agent.h"

#include <QObject>

class NetworkAgentToken;

class NetworkAgent : public QObject
{
    Q_OBJECT
public:
    NetworkAgent(QObject *parent=0);
    ~NetworkAgent();

    Q_INVOKABLE void authenticate(const QVariant &token, const QString &key);
    Q_INVOKABLE void cancel(const QVariant &token);

Q_SIGNALS:
    void secretRequested(const QVariant &token);
    void secretRequestCancelled();

private:
    UnitySettingsSecretAgent *m_agent;

    static void onSecretRequested(UnitySettingsSecretAgent *agent,
                                  guint   id,
                                  NMConnection *connection,
                                  const char *setting_name,
                                  const char **hints,
                                  NMSecretAgentGetSecretsFlags flags,
                                  NetworkAgent *self);

    static void onSecretRequestCancelled(UnitySettingsSecretAgent *agent,
                                         guint          id,
                                         NMConnection *connection,
                                         const char *setting_name,
                                         const char **hints,
                                         NMSecretAgentGetSecretsFlags flags,
                                         NetworkAgent *self);

};

#endif
