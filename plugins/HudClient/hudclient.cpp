/*
 * Copyright (C) 2012, 2013 Canonical, Ltd.
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

#include "hudclient.h"

#include "hudtoolbarmodel.h"

#include <deelistmodel.h>

#include <QDebug>

namespace
{

extern "C"
{

void loadingCB(GObject* /*src*/, gpointer dst)
{
    static_cast<HudClient*>(dst)->voiceQueryLoading();
}

void listeningCB(GObject* /*src*/, gpointer dst)
{
    static_cast<HudClient*>(dst)->voiceQueryListening();
}

void heardSomethingCB(GObject* /*src*/, gpointer dst)
{
    static_cast<HudClient*>(dst)->voiceQueryHeardSomething();
}

void failedCB(GObject* /*src*/, const gchar * /*reason*/, gpointer dst)
{
    static_cast<HudClient*>(dst)->voiceQueryFailed();
}

void finishedCB(GObject* /*src*/, const gchar* query, gpointer dst)
{
    static_cast<HudClient*>(dst)->voiceQueryFinished(QString::fromUtf8(query));
}

void modelReadyCB(GObject* /*src*/, gpointer dst)
{
    static_cast<HudClient*>(dst)->modelReady(true);
}

void modelReallyReadyCB(GObject* /*src*/, gint /*position*/, gint /*removed*/, gint /*added*/, gpointer dst)
{
    static_cast<HudClient*>(dst)->modelReallyReady(true);
}

static void modelsChangedCB(GObject* /*src*/, gpointer dst)
{
    static_cast<HudClient*>(dst)->queryModelsChanged();
}

static void toolBarUpdatedCB(GObject* /*src*/, gpointer dst)
{
    static_cast<HudToolBarModel*>(dst)->updatedByBackend();
}

} // extern "C"

} // namespace

HudClient::HudClient()
{
    m_results = new DeeListModel();
    m_clientQuery = hud_client_query_new("");
    m_toolBarModel = new HudToolBarModel(m_clientQuery);
    m_currentActionParam = nullptr;
    m_results->setModel(hud_client_query_get_results_model(m_clientQuery));

    g_signal_connect(G_OBJECT(m_clientQuery), "voice-query-loading", G_CALLBACK(loadingCB), this);
    g_signal_connect(G_OBJECT(m_clientQuery), "voice-query-listening", G_CALLBACK(listeningCB), this);
    g_signal_connect(G_OBJECT(m_clientQuery), "voice-query-heard-something", G_CALLBACK(heardSomethingCB), this);
    g_signal_connect(G_OBJECT(m_clientQuery), "voice-query-finished", G_CALLBACK(finishedCB), this);
    g_signal_connect(G_OBJECT(m_clientQuery), "voice-query-failed", G_CALLBACK(failedCB), this);
    g_signal_connect(G_OBJECT(m_clientQuery), HUD_CLIENT_QUERY_SIGNAL_MODELS_CHANGED, G_CALLBACK(modelsChangedCB), this);
    g_signal_connect(G_OBJECT(m_clientQuery), HUD_CLIENT_QUERY_SIGNAL_TOOLBAR_UPDATED, G_CALLBACK(toolBarUpdatedCB), m_toolBarModel);
}

// Terrible hack to get around GLib. GLib stores function pointers as gpointer, which violates the C and C++ spec
// because data and function pointers may have different sizes. gcc rightfully emits a warning. There is no #pragma
// in gcc to selectively turn off the warning, however. This hack gets around the problem, by using a union (ick) to
// convert between the two types.

class ToGPointer
{
public:
    ToGPointer(void (*cb)())
    {
        u_.cb = cb;
    }

    operator gpointer()
    {
        return u_.p;
    }

private:
    union
    {
        void (*cb)();
        gpointer p;
    } u_;
};

#define TO_GPOINTER(cb) (ToGPointer(reinterpret_cast<void(*)()>((cb))))

HudClient::~HudClient()
{
    g_signal_handlers_disconnect_by_func(G_OBJECT(m_clientQuery), TO_GPOINTER(loadingCB), this);
    g_signal_handlers_disconnect_by_func(G_OBJECT(m_clientQuery), TO_GPOINTER(listeningCB), this);
    g_signal_handlers_disconnect_by_func(G_OBJECT(m_clientQuery), TO_GPOINTER(heardSomethingCB), this);
    g_signal_handlers_disconnect_by_func(G_OBJECT(m_clientQuery), TO_GPOINTER(finishedCB), this);
    g_signal_handlers_disconnect_by_func(G_OBJECT(m_clientQuery), TO_GPOINTER(toolBarUpdatedCB), m_toolBarModel);

    delete m_results;
    delete m_toolBarModel;

    g_object_unref(m_clientQuery);
}

void HudClient::setQuery(const QString &new_query)
{
    hud_client_query_set_query(m_clientQuery, new_query.toUtf8().constData());
}

void HudClient::startVoiceQuery()
{
    hud_client_query_voice_query(m_clientQuery);
}

void HudClient::executeParametrizedAction(const QVariant &values)
{
    updateParametrizedAction(values);
    hud_client_param_send_commit(m_currentActionParam);
    g_object_unref(m_currentActionParam);
    m_currentActionParam = nullptr;
    Q_EMIT commandExecuted();
}

void HudClient::updateParametrizedAction(const QVariant &values)
{
    if (m_currentActionParam != nullptr) {
        const QVariantMap map = values.value<QVariantMap>();
        GActionGroup *ag = hud_client_param_get_actions(m_currentActionParam);

        auto it = map.begin();
        for ( ; it != map.end(); ++it) {
            const QString action = it.key();
            const QVariant value = it.value();
            const GVariantType *actionType = g_action_group_get_action_parameter_type(ag, action.toUtf8().constData());
            if (g_variant_type_equal(actionType, G_VARIANT_TYPE_DOUBLE) && value.canConvert(QVariant::Double)) {
                g_action_group_activate_action(ag, action.toUtf8().constData(), g_variant_new_double(value.toDouble()));
            } else {
                qWarning() << "Unsuported action type in HudClient::executeParametrizedAction";
            }
        }
    } else {
        qWarning() << "Got to HudClient::updateParametrizedAction with no m_currentActionParam";
    }
}

void HudClient::cancelParametrizedAction()
{
    if (m_currentActionParam != nullptr) {
        hud_client_param_send_cancel(m_currentActionParam);
        g_object_unref(m_currentActionParam);
        m_currentActionParam = nullptr;
    }
}

void HudClient::executeToolBarAction(HudClientQueryToolbarItems action)
{
    hud_client_query_execute_toolbar_item(m_clientQuery, action, /* timestamp */ 0);
    Q_EMIT commandExecuted();
}

DeeListModel *HudClient::results() const
{
    return m_results;
}

QAbstractItemModel *HudClient::toolBarModel() const
{
    return m_toolBarModel;
}

void HudClient::executeCommand(int index)
{
    m_currentActionIndex = index;
    DeeModel *model = hud_client_query_get_results_model(m_clientQuery);
    DeeModelIter *iter = dee_model_get_iter_at_row(model, index);

    GVariant *command_key = dee_model_get_value(model, iter, 0);
    GVariant *is_parametrized = dee_model_get_value(model, iter, 7);
    if (g_variant_get_boolean(is_parametrized)) {
        m_currentActionParam = hud_client_query_execute_param_command(m_clientQuery, command_key, /* timestamp */ 0);
        if (m_currentActionParam != nullptr) {
            GMenuModel *menuModel = hud_client_param_get_model (m_currentActionParam);
            if (menuModel == nullptr) {
                g_signal_connect(m_currentActionParam, HUD_CLIENT_PARAM_SIGNAL_MODEL_READY, G_CALLBACK(modelReadyCB), this);
            } else {
                modelReady(false);
            }
        } else {
            qWarning() << "HudClient::executeCommand::Could not get the HudClientParam for parametrized action with index" << index;
        }
    } else {
        hud_client_query_execute_command(m_clientQuery, command_key, /* timestamp */ 0);
        Q_EMIT commandExecuted();
    }
    g_variant_unref(command_key);
    g_variant_unref(is_parametrized);
}

void HudClient::modelReady(bool needDisconnect)
{
    if (needDisconnect) {
        g_signal_handlers_disconnect_by_func(m_currentActionParam, TO_GPOINTER(modelReadyCB), this);
    }
    GMenuModel *menuModel = hud_client_param_get_model (m_currentActionParam);
    if (g_menu_model_get_n_items(menuModel) == 0) {
        g_signal_connect(menuModel, "items-changed", G_CALLBACK(modelReallyReadyCB), this);
    } else {
        modelReallyReady(false);
    }
}

static void addAttribute(QVariantMap &properties, GMenuModel *menuModel, int item, const char *attribute) {
    GVariant *v = g_menu_model_get_item_attribute_value(menuModel, item, attribute, nullptr);

    if (v == nullptr)
        return;

    properties.insert(attribute, DeeListModel::VariantForData(v));
    g_variant_unref(v);
}

void HudClient::modelReallyReady(bool needDisconnect)
{
    GMenuModel *menuModel = hud_client_param_get_model (m_currentActionParam);
    if (needDisconnect) {
        g_signal_handlers_disconnect_by_func(menuModel, TO_GPOINTER(modelReallyReadyCB), this);
    }

    QVariantList items;
    for (int i = 0; i < g_menu_model_get_n_items(menuModel); i++) {
        GVariant *v = g_menu_model_get_item_attribute_value(menuModel, i, "parameter-type", G_VARIANT_TYPE_STRING);

        if (v == nullptr)
            continue;

        const QString type = QString::fromUtf8(g_variant_get_string(v, nullptr));
        if (type == "slider") {
            const char *sliderAttributes[] = { "label", "min", "max", "step", "value", "live", "action" };
            QVariantMap properties;
            properties.insert("parameter-type", "slider");
            for (uint j = 0; j < sizeof(sliderAttributes)/sizeof(sliderAttributes[0]); ++j) {
                addAttribute(properties, menuModel, i, sliderAttributes[j]);
            }
            items << properties;
        }
        g_variant_unref(v);
    }

    DeeModel *model = hud_client_query_get_results_model(m_clientQuery);
    DeeModelIter *iter = dee_model_get_iter_at_row(model, m_currentActionIndex);
    GVariant *actionTextVariant = dee_model_get_value(model, iter, 1);
    const QString actionText = QString::fromUtf8(g_variant_get_string(actionTextVariant, nullptr));
    g_variant_unref(actionTextVariant);
    Q_EMIT showParametrizedAction(actionText, QVariant::fromValue(items));
}

void HudClient::queryModelsChanged()
{
    m_results->setModel(hud_client_query_get_results_model(m_clientQuery));
}
