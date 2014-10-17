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
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

#include "rootactionstate.h"
#include "indicators.h"

#include <unitymenumodel.h>
#include <QVariant>
#include <QIcon>

extern "C" {
#include <glib.h>
#include <gio/gio.h>
}

RootActionState::RootActionState(QObject *parent)
    : ActionStateParser(parent),
      m_menu(nullptr)
{
}

RootActionState::~RootActionState()
{
}

UnityMenuModel* RootActionState::menu() const
{
    return m_menu;
}

void RootActionState::setMenu(UnityMenuModel* menu)
{
    if (m_menu != menu) {
        if (m_menu) {
            m_menu->disconnect(this);
        }
        m_menu = menu;

        if (m_menu) {
            connect(m_menu, SIGNAL(rowsInserted(const QModelIndex&, int, int)), SLOT(onModelRowsAdded(const QModelIndex&, int, int)));
            connect(m_menu, SIGNAL(rowsRemoved(const QModelIndex&, int, int)), SLOT(onModelRowsRemoved(const QModelIndex&, int, int)));
            connect(m_menu, SIGNAL(dataChanged(const QModelIndex&, const QModelIndex&, const QVector<int>&)), SLOT(onModelDataChanged(const QModelIndex&, const QModelIndex&, const QVector<int>&)));

            connect(m_menu, SIGNAL(destroyed()), SLOT(reset()));
        }
        updateActionState();
        Q_EMIT menuChanged();
    }
}

void RootActionState::onModelRowsAdded(const QModelIndex& parent, int start, int end)
{
    Q_UNUSED(parent);
    if (start == 0 && end >= 0) {
        updateActionState();
    }
}

void RootActionState::onModelRowsRemoved(const QModelIndex& parent, int start, int end)
{
    Q_UNUSED(parent);
    if (start == 0 && end >= 0) {
        updateActionState();
    }
}

void RootActionState::onModelDataChanged(const QModelIndex& topLeft, const QModelIndex& bottomRight, const QVector<int>& roles)
{
    Q_UNUSED(roles);
    if (!topLeft.isValid() || !bottomRight.isValid()) {
        return;
    }

    if (topLeft.row() <= 0 && bottomRight.row() >= 0) {
        updateActionState();
    }
}

void RootActionState::reset()
{
    m_cachedState.clear();
    m_menu = nullptr;

    Q_EMIT menuChanged();
    Q_EMIT updated();
}

void RootActionState::updateActionState()
{
    if (m_menu && m_menu->rowCount() > 0) {
        ActionStateParser* oldParser = m_menu->actionStateParser();
        m_menu->setActionStateParser(this);

        m_cachedState = m_menu->get(0, "actionState").toMap();

        m_menu->setActionStateParser(oldParser);
    } else {
        m_cachedState.clear();
    }
    Q_EMIT updated();
}

bool RootActionState::isValid() const
{
    return m_menu && m_menu->rowCount() > 0;
}

QString RootActionState::title() const
{
    if (!isValid()) return QString();

    return m_cachedState.value("title", QVariant::fromValue(QString())).toString();
}

QString RootActionState::leftLabel() const
{
    if (!isValid()) return QString();

    return m_cachedState.value("pre-label", QVariant::fromValue(QString())).toString();
}

QString RootActionState::rightLabel() const
{
    if (!isValid()) return QString();

    return m_cachedState.value("label", QVariant::fromValue(QString())).toString();
}

QStringList RootActionState::icons() const
{
    if (!isValid()) return QStringList();

    return m_cachedState.value("icons", QVariant::fromValue(QStringList())).toStringList();
}

QString RootActionState::accessibleName() const
{
    if (!isValid()) return QString();

    return m_cachedState.value("accessible-desc", QVariant::fromValue(QString())).toString();
}

bool RootActionState::isIndicatorVisible() const
{
    if (!isValid()) return false;

    return m_cachedState.value("visible", QVariant::fromValue(true)).toBool();
}

static QString iconUri(GIcon *icon)
{
    QString uri;

    if (G_IS_THEMED_ICON (icon)) {
        const gchar* const* iconNames = g_themed_icon_get_names (G_THEMED_ICON (icon));

        QStringList iconNameList;
        for (uint index = 0; iconNames[index] != nullptr; index++) {
            iconNameList << iconNames[index];
        }

        if (!iconNameList.empty()) {
            uri = QString("image://theme/%1").arg(iconNameList.join(","));
        }
    }
    else if (G_IS_FILE_ICON (icon)) {
        GFile *file;

        file = g_file_icon_get_file (G_FILE_ICON (icon));
        if (g_file_is_native (file)) {
            gchar *fileuri;

            fileuri = g_file_get_path (file);
            uri = QString(fileuri);

            g_free (fileuri);
        }
    }
    else if (G_IS_BYTES_ICON (icon)) {
        gsize size;
        gconstpointer data;
        gchar *base64;

        data = g_bytes_get_data (g_bytes_icon_get_bytes (G_BYTES_ICON (icon)), &size);
        base64 = g_base64_encode ((const guchar *) data, size);

        uri = QString("data://");
        uri.append (base64);

        g_free (base64);
    }

    return uri;
}

QVariant RootActionState::toQVariant(GVariant* state) const
{
    if (!state) {
        return QVariant();
    }

    if (g_variant_is_of_type(state, G_VARIANT_TYPE_VARDICT)) {
        GVariantIter iter;
        GVariant *vvalue;
        gchar *key;
        QVariantMap qmap;

        g_variant_iter_init (&iter, state);
        while (g_variant_iter_loop (&iter, "{sv}", &key, &vvalue))
        {
            QString str = QString::fromUtf8(key);
            if (str == "icon" && !qmap.contains("icons")) {
                QStringList icons;

                // FIXME - should be sending a url.
                GIcon *gicon = g_icon_deserialize (vvalue);
                if (gicon) {
                    icons << iconUri(gicon);
                    g_object_unref (gicon);
                }
                qmap.insert("icons", icons);

            } else if (str == "icons") {

                QStringList icons;

                if (g_variant_is_of_type(vvalue, G_VARIANT_TYPE("av"))) {
                    GVariantIter iter;
                    GVariant *val = 0;
                    g_variant_iter_init (&iter, vvalue);
                    while (g_variant_iter_loop (&iter, "v", &val))
                    {
                        // FIXME - should be sending a url.
                        GIcon *gicon = g_icon_deserialize (val);
                        if (gicon) {
                            icons << iconUri(gicon);
                            g_object_unref (gicon);
                        }
                    }
                }
                // will overwrite icon.
                qmap.insert("icons", icons);

            } else {
                qmap.insert(str, ActionStateParser::toQVariant(vvalue));
            }
        }

        return QVariant::fromValue(qmap);

    } else if (g_variant_is_of_type (state, G_VARIANT_TYPE ("(sssb)"))) {
        QVariantMap qmap;

        char* label;
        char* icon;
        char* accessible_name;
        gboolean visible;
        GIcon *gicon;

        g_variant_get(state, "(sssb)", &label,
                                       &icon,
                                       &accessible_name,
                                       &visible);

        qmap["label"] = label ? QString::fromUtf8(label) : "";
        qmap["accessible-desc"] = accessible_name ? QString::fromUtf8(accessible_name) : "";
        qmap["visible"] = visible;

        gicon = g_icon_new_for_string (icon, nullptr);
        if (gicon) {
            qmap["icons"] = QStringList() << iconUri(gicon);
            g_object_unref (gicon);
        }

        if (label) g_free(label);
        if (icon) g_free(icon);
        if (accessible_name) g_free(accessible_name);

        return QVariant::fromValue(qmap);
    }
    return ActionStateParser::toQVariant(state);
}
