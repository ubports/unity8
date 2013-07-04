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


#include <glib.h>
#include <glib-object.h>
#include <nm-secret-agent.h>
#include "secret-agent.h"

#define UNITY_SETTINGS_TYPE_SECRET_AGENT (unity_settings_secret_agent_get_type ())
#define UNITY_SETTINGS_SECRET_AGENT(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), UNITY_SETTINGS_TYPE_SECRET_AGENT, UnitySettingsSecretAgent))
#define UNITY_SETTINGS_SECRET_AGENT_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), UNITY_SETTINGS_TYPE_SECRET_AGENT, UnitySettingsSecretAgentClass))
#define UNITY_SETTINGS_IS_SECRET_AGENT(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), UNITY_SETTINGS_TYPE_SECRET_AGENT))
#define UNITY_SETTINGS_IS_SECRET_AGENT_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), UNITY_SETTINGS_TYPE_SECRET_AGENT))
#define UNITY_SETTINGS_SECRET_AGENT_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), UNITY_SETTINGS_TYPE_SECRET_AGENT, UnitySettingsSecretAgentClass))
#define UNITY_SETTINGS_SECRET_AGENT_GET_PRIVATE(o) (G_TYPE_INSTANCE_GET_PRIVATE ((o), UNITY_SETTINGS_TYPE_SECRET_AGENT, UnitySettingsSecretAgentPrivate))

#define AGENT_ID "com.canonical.settings.network.nm-agent"

static gpointer unity_settings_secret_agent_parent_class = NULL;

typedef struct _UnitySettingsSecretAgentPrivate UnitySettingsSecretAgentPrivate;

struct _UnitySettingsSecretAgentPrivate {
  GQueue  *requests;
};

typedef struct _SecretRequest {
  gint                           id;
  NMSecretAgent                 *agent;
  NMConnection                  *connection;
  const char                    *connection_path;
  const char                    *setting_name;
  const char                   **hints;
  NMSecretAgentGetSecretsFlags   flags;
  NMSecretAgentGetSecretsFunc    callback;
  gpointer                       callback_data;
} SecretRequest;

GType unity_settings_secret_agent_get_type (void) G_GNUC_CONST;
enum  {
    UNITY_SETTINGS_SECRET_AGENT_DUMMY_PROPERTY
};

enum {
  SECRET_REQUESTED,
  REQUEST_CANCELLED,
  LAST_SIGNAL
};

static guint signals[LAST_SIGNAL] = { 0 };

UnitySettingsSecretAgent* unity_settings_secret_agent_new       (void);
UnitySettingsSecretAgent* unity_settings_secret_agent_construct (GType object_type);

int
secret_request_find (SecretRequest  *req,
                     guint          *id)
{
  if (req->id > *id)
      return -1;

  if (req->id < *id)
      return 1;

  return 0;
}

void
unity_settings_secret_agent_provide_secret (UnitySettingsSecretAgent *agent,
                                            guint                     request,
                                            GHashTable               *secrets)
{
  GList                           *iter;
  SecretRequest                   *req;
  UnitySettingsSecretAgentPrivate *priv = agent->priv;

  iter = g_queue_find_custom (priv->requests,
                              &request,
                              (GCompareFunc)secret_request_find);

  if (iter == NULL || iter->data == NULL)
    {
      g_warning ("Secret request with id <%d> was not found", (int)request);
      return;
    }

  req = iter->data;

  req->callback (NM_SECRET_AGENT (agent),
                 req->connection,
                 secrets,
                 NULL,
                 req->callback_data);

  g_queue_remove_all (priv->requests, req);
  g_free (req);
  return;
}

void
free_request (SecretRequest *req)
{
  g_object_unref (req->connection);
  g_free (req);
}

void
unity_settings_secret_agent_cancel_request (UnitySettingsSecretAgent *agent,
                                            guint                     request)
{
  GList                           *iter;
  SecretRequest                   *req;
  UnitySettingsSecretAgentPrivate *priv = agent->priv;
  GError *error;

  iter = g_queue_find_custom (priv->requests,
                              &request,
                              (GCompareFunc)secret_request_find);

  if (iter == NULL || iter->data == NULL)
    {
      g_warning ("Secret request with id <%d> was not found", (int)request);
      return;
    }

  req = iter->data;
  error = g_error_new (NM_SECRET_AGENT_ERROR,
                       NM_SECRET_AGENT_ERROR_INTERNAL_ERROR,
                       "This secret request was canceled by the user.");

  req->callback (NM_SECRET_AGENT (agent),
                 req->connection,
                 NULL,
                 error,
                 req->callback_data);

  g_queue_remove_all (priv->requests, req);
  free_request (req);
  return;
}

static void
delete_secrets (NMSecretAgent *agent,
                NMConnection *connection,
                const char *connection_path,
                NMSecretAgentDeleteSecretsFunc callback,
                gpointer callback_data)
{
  g_debug ("delete secrets");
}

/* If it returns G_MAXUINT it's considered an error */
static guint
find_available_id (UnitySettingsSecretAgentPrivate *priv)
{
  guint i         = 0;
  guint candidate = 0;

  if (g_queue_get_length (priv->requests) == G_MAXUINT)
    return G_MAXUINT;

  while (i < g_queue_get_length (priv->requests))
    {
      SecretRequest *req = (SecretRequest*)g_queue_peek_nth (priv->requests, i);

      if (req->id == candidate)
      {
        candidate++;
        i = 0;
      }
      else
      {
        i++;
      }
    }

  return i;
}

static void
get_secrets (NMSecretAgent                 *agent,
             NMConnection                  *connection,
             const char                    *connection_path,
             const char                    *setting_name,
             const char                   **hints,
             NMSecretAgentGetSecretsFlags   flags,
             NMSecretAgentGetSecretsFunc    callback,
             gpointer                       callback_data)
{
  guint   id;
  UnitySettingsSecretAgentPrivate *priv = UNITY_SETTINGS_SECRET_AGENT_GET_PRIVATE (agent);
  SecretRequest *req = NULL;

  if (flags == NM_SECRET_AGENT_GET_SECRETS_FLAG_NONE)
    {
      GError *error = g_error_new (NM_SECRET_AGENT_ERROR,
                                   NM_SECRET_AGENT_ERROR_INTERNAL_ERROR,
                                   "No password found for this connection.");
      callback (agent, connection, NULL, error, callback_data);
      g_error_free (error);
      return;
    }

  id = find_available_id (priv);
  if (id == G_MAXUINT)
    {
      GError *error = g_error_new (NM_SECRET_AGENT_ERROR,
                                   NM_SECRET_AGENT_ERROR_INTERNAL_ERROR,
                                   "Reached maximum number of requests.");
      callback (agent, connection, NULL, error, callback_data);
      g_error_free (error);
      return;
    }

  /* Adding a request */
  req = (SecretRequest*) g_malloc0 (sizeof (SecretRequest));
  *req = ((SecretRequest)
          { id,
            agent,
            connection,
            connection_path,
            setting_name,
            hints,
            flags,
            callback,
            callback_data });

  g_object_ref (connection);

  g_queue_push_tail (priv->requests, req);

  g_signal_emit_by_name (agent,
                         UNITY_SETTINGS_SECRET_AGENT_SECRET_REQUESTED,
                         id,
                         connection,
                         setting_name,
                         hints,
                         flags);
}

static void
save_secrets (NMSecretAgent                *agent,
              NMConnection                 *connection,
              const char                   *connection_path,
              NMSecretAgentSaveSecretsFunc  callback,
              gpointer                      callback_data)
{
  g_debug ("save secrets");
}

static void
cancel_get_secrets (NMSecretAgent *agent,
                    const char *connection_path,
                    const char *setting_name)
{
  g_debug ("cancel get secrets");
}

UnitySettingsSecretAgent*
unity_settings_secret_agent_construct (GType object_type)
{
  UnitySettingsSecretAgent * self = NULL;
  self = (UnitySettingsSecretAgent*) g_object_new (object_type,
                                                   NM_SECRET_AGENT_IDENTIFIER, AGENT_ID,
                                                   NULL);
  return self;
}


UnitySettingsSecretAgent*
unity_settings_secret_agent_new (void)
{
  return unity_settings_secret_agent_construct (UNITY_SETTINGS_TYPE_SECRET_AGENT);
}

static void
destroy_pending_request (gpointer data)
{
  SecretRequest* req = (SecretRequest*)data;
  /* Reporting the cancellation of all pending requests */
  g_signal_emit_by_name (req->agent,
                         UNITY_SETTINGS_SECRET_AGENT_REQUEST_CANCELLED,
                         req->id);

  free_request (req);
}

static void
unity_settings_secret_agent_finalize (GObject *agent)
{
  UnitySettingsSecretAgentPrivate *priv = UNITY_SETTINGS_SECRET_AGENT_GET_PRIVATE (agent);

  g_queue_free_full (priv->requests, destroy_pending_request);
}

static void
unity_settings_secret_agent_class_init (UnitySettingsSecretAgentClass *klass)
{
  unity_settings_secret_agent_parent_class = g_type_class_peek_parent (klass);
  NMSecretAgentClass         *parent_class = NM_SECRET_AGENT_CLASS (klass);
  parent_class->get_secrets = get_secrets;
  parent_class->save_secrets = save_secrets;
  parent_class->delete_secrets = delete_secrets;
  parent_class->cancel_get_secrets = cancel_get_secrets;

  g_type_class_add_private (klass, sizeof(UnitySettingsSecretAgentPrivate));
  G_OBJECT_CLASS (klass)->finalize = unity_settings_secret_agent_finalize;


  signals[SECRET_REQUESTED] = g_signal_new (UNITY_SETTINGS_SECRET_AGENT_SECRET_REQUESTED,
                                            G_OBJECT_CLASS_TYPE (G_OBJECT_CLASS (klass)),
                                            G_SIGNAL_RUN_FIRST,
                                            G_STRUCT_OFFSET (UnitySettingsSecretAgentClass, secret_requested),
                                            NULL, NULL, NULL,
                                            G_TYPE_NONE, 5,
                                            G_TYPE_UINT, G_TYPE_POINTER, G_TYPE_STRING, G_TYPE_POINTER, G_TYPE_UINT);

  signals[REQUEST_CANCELLED] = g_signal_new (UNITY_SETTINGS_SECRET_AGENT_REQUEST_CANCELLED,
                                             G_OBJECT_CLASS_TYPE (G_OBJECT_CLASS (klass)),
                                             G_SIGNAL_RUN_FIRST,
                                             G_STRUCT_OFFSET (UnitySettingsSecretAgentClass, request_cancelled),
                                             NULL, NULL, NULL,
                                             G_TYPE_NONE, 1,
                                             G_TYPE_UINT);
}


static void
unity_settings_secret_agent_instance_init (UnitySettingsSecretAgent *self)
{
  self->priv = UNITY_SETTINGS_SECRET_AGENT_GET_PRIVATE (self);
  self->priv->requests = g_queue_new ();
}

GType
unity_settings_secret_agent_get_type (void)
{
  static volatile gsize unity_settings_secret_agent_type_id__volatile = 0;
  if (g_once_init_enter (&unity_settings_secret_agent_type_id__volatile))
    {
      static const GTypeInfo g_define_type_info =
        {
          sizeof (UnitySettingsSecretAgentClass),
          (GBaseInitFunc) NULL,
          (GBaseFinalizeFunc) NULL,
          (GClassInitFunc) unity_settings_secret_agent_class_init,
          (GClassFinalizeFunc) NULL,
          NULL,
          sizeof (UnitySettingsSecretAgent),
          0,
          (GInstanceInitFunc) unity_settings_secret_agent_instance_init,
          NULL
        };
      GType unity_settings_secret_agent_type_id;
      unity_settings_secret_agent_type_id = g_type_register_static (NM_TYPE_SECRET_AGENT,
                                                                    "UnitySettingsSecretAgent",
                                                                    &g_define_type_info,
                                                                    0);
      g_once_init_leave (&unity_settings_secret_agent_type_id__volatile,
                         unity_settings_secret_agent_type_id);
    }

  return unity_settings_secret_agent_type_id__volatile;
}
