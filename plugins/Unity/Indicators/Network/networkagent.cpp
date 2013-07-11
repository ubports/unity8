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

#include "networkagent.h"

#include <QVariant>
#include <QApplication>
#include <QDebug>

class NetworkAgentToken
{
public:
    NMConnection *connection;
    NMSettingWirelessSecurity *wisec;
    guint id;
    QByteArray keyMgmt;

    NetworkAgentToken(NMConnection *connection,
                      NMSettingWirelessSecurity *wisec,
                      guint id,
                      QByteArray keyMgmt)
        : connection(connection),
          wisec(wisec),
          id(id),
          keyMgmt(keyMgmt)
    {
        if (connection) {
            g_object_ref(connection);
        } else {
            qWarning() << "invalid connection object";
        }
    }

    ~NetworkAgentToken()
    {
        if (connection) {
            g_object_unref(connection);
        }
    }
};

NetworkAgent::NetworkAgent(QObject *parent)
    : QObject(parent)
{
    m_agent = unity_settings_secret_agent_new();
    g_signal_connect(G_OBJECT(m_agent),
                     UNITY_SETTINGS_SECRET_AGENT_SECRET_REQUESTED,
                     G_CALLBACK(onSecretRequested),
                     this);

    g_signal_connect(G_OBJECT(m_agent),
                     UNITY_SETTINGS_SECRET_AGENT_REQUEST_CANCELLED,
                     G_CALLBACK(onSecretRequestCancelled),
                     this);
}

NetworkAgent::~NetworkAgent()
{
    nm_secret_agent_unregister(NM_SECRET_AGENT(m_agent));
    g_object_unref(m_agent);
}

void NetworkAgent::authenticate(const QVariant &token, const QString &key)
{
    NetworkAgentToken *pToken = (NetworkAgentToken *) token.value<void *>();
    if (pToken == NULL) {
        return;
    }

    if ((pToken->keyMgmt == "wpa-none") || (pToken->keyMgmt == "wpa-psk")) {
        g_object_set(G_OBJECT(pToken->wisec),
                     NM_SETTING_WIRELESS_SECURITY_PSK, qPrintable(key),
                     NULL);
    } else if (pToken->keyMgmt == "none") {
        g_object_set(G_OBJECT(pToken->wisec),
                     NM_SETTING_WIRELESS_SECURITY_WEP_KEY0, qPrintable(key),
                     NULL);
    }

    GHashTable *settings = nm_connection_to_hash(pToken->connection,
                                                 NM_SETTING_HASH_FLAG_ALL);

    unity_settings_secret_agent_provide_secret(m_agent,
                                               pToken->id, settings);
    g_hash_table_unref(settings);
    delete pToken;
}

void NetworkAgent::cancel(const QVariant &token)
{
    NetworkAgentToken *pToken = (NetworkAgentToken *) token.value<void *>();
    if (pToken != NULL) {
        unity_settings_secret_agent_cancel_request(m_agent, pToken->id);
        delete pToken;
    }
}

void NetworkAgent::onSecretRequested(UnitySettingsSecretAgent* /*agent*/,
                                     guint         id,
                                     NMConnection* connection,
                                     const char* /*setting_name*/,
                                     const char** /*hints*/,
                                     NMSecretAgentGetSecretsFlags /*flags*/,
                                     NetworkAgent* self)
{
    NetworkAgentToken *token = new NetworkAgentToken(connection,
                                                     NULL,
                                                     id,
                                                     NULL);

    token->wisec = nm_connection_get_setting_wireless_security(connection);
    if (token->wisec) {
        token->keyMgmt = nm_setting_wireless_security_get_key_mgmt(token->wisec);
    }

    QVariant varToken = qVariantFromValue((void *) token);
    Q_EMIT self->secretRequested(varToken);
}

void NetworkAgent::onSecretRequestCancelled(UnitySettingsSecretAgent* /*agent*/,
                                            guint         /*id*/,
                                            NMConnection* /*connection*/,
                                            const char* /*setting_name*/,
                                            const char** /*hints*/,
                                            NMSecretAgentGetSecretsFlags /*flags*/,
                                            NetworkAgent* /*self*/)
{
    //Do nothing for now
}
