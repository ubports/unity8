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

#ifndef __SECRET_AGENT_H__
#define __SECRET_AGENT_H__

#include <glib.h>
#include <glib-object.h>
#include <nm-secret-agent.h>

/*
 * This class is a basic implementation of the NetworkManager SecretAgent base class.
 *
 * The purpose of this class is to handle credential requests from the network,
 * for example, from a WiFi hotspot or a VPN network.
 *
 * It queues requests objects (SecretRequest) on a GQueue in the private struct
 * of the class. And notifies the consumer of the class through the "secret-request"
 * and the "request-cancelled" signals with the following callback prototypes:
 *
 * void  (*secret_requested) (UnitySettingsSecretAgent      *self,
 *                            guint                        id,
 *                            NMConnection                  *connection,
 *                            const char                    *setting_name,
 *                            const char                   **hints,
 *                            NMSecretAgentGetSecretsFlags   flags,
 *                            gpointer                       user_data);
 *
 * void  (*request_cancelled) (UnitySettingsSecretAgent      *self,
 *                             guint                        id,
 *                             gpointer                       user_data);
 *
 */


G_BEGIN_DECLS


#define UNITY_SETTINGS_TYPE_SECRET_AGENT (unity_settings_secret_agent_get_type ())
#define UNITY_SETTINGS_SECRET_AGENT(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), UNITY_SETTINGS_TYPE_SECRET_AGENT, UnitySettingsSecretAgent))
#define UNITY_SETTINGS_SECRET_AGENT_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), UNITY_SETTINGS_TYPE_SECRET_AGENT, UnitySettingsSecretAgentClass))
#define UNITY_SETTINGS_IS_SECRET_AGENT(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), UNITY_SETTINGS_TYPE_SECRET_AGENT))
#define UNITY_SETTINGS_IS_SECRET_AGENT_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), UNITY_SETTINGS_TYPE_SECRET_AGENT))
#define UNITY_SETTINGS_SECRET_AGENT_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), UNITY_SETTINGS_TYPE_SECRET_AGENT, UnitySettingsSecretAgentClass))

#define UNITY_SETTINGS_SECRET_AGENT_SECRET_REQUESTED  "secret-requested"
#define UNITY_SETTINGS_SECRET_AGENT_REQUEST_CANCELLED "request-cancelled"

typedef struct _UnitySettingsSecretAgent UnitySettingsSecretAgent;
typedef struct _UnitySettingsSecretAgentClass UnitySettingsSecretAgentClass;
typedef struct _UnitySettingsSecretAgentPrivate UnitySettingsSecretAgentPrivate;

struct _UnitySettingsSecretAgent {
  NMSecretAgent parent_instance;
  UnitySettingsSecretAgentPrivate * priv;
};

struct _UnitySettingsSecretAgentClass {
  NMSecretAgentClass parent_class;

  void  (*secret_requested) (UnitySettingsSecretAgent      *self,
                             guint                          id,
                             NMConnection                  *connection,
                             const char                    *setting_name,
                             const char                   **hints,
                             NMSecretAgentGetSecretsFlags   flags);

  void  (*request_cancelled) (UnitySettingsSecretAgent      *self,
                              guint                          id);
};


GType                     unity_settings_secret_agent_get_type  (void) G_GNUC_CONST;
UnitySettingsSecretAgent* unity_settings_secret_agent_new       (void);
UnitySettingsSecretAgent* unity_settings_secret_agent_construct (GType object_type);

void unity_settings_secret_agent_provide_secret (UnitySettingsSecretAgent *agent,
                                                 guint                     request,
                                                 GHashTable               *secrets);
void unity_settings_secret_agent_cancel_request (UnitySettingsSecretAgent *agent,
                                                 guint                     request);

G_END_DECLS

#endif
