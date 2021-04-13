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
 */

#include "rootstateparser.h"

extern "C" {
#include <glib.h>
#include <gio/gio.h>
}

RootStateParser::RootStateParser(QObject* parent)
    : ActionStateParser(parent)
{
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
            uri = QStringLiteral("image://theme/%1").arg(iconNameList.join(QStringLiteral(",")));
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

        uri = QStringLiteral("data://");
        uri.append (base64);

        g_free (base64);
    }

    return uri;
}

QVariant RootStateParser::toQVariant(GVariant* state) const
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
            if (str == QLatin1String("icon") && !qmap.contains(QStringLiteral("icons"))) {
                QStringList icons;

                // FIXME - should be sending a url.
                GIcon *gicon = g_icon_deserialize (vvalue);
                if (gicon) {
                    icons << iconUri(gicon);
                    g_object_unref (gicon);
                }
                qmap.insert(QStringLiteral("icons"), icons);

            } else if (str == QLatin1String("icons")) {

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
                qmap.insert(QStringLiteral("icons"), icons);

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

        qmap[QStringLiteral("label")] = label ? QString::fromUtf8(label) : QLatin1String("");
        qmap[QStringLiteral("accessible-desc")] = accessible_name ? QString::fromUtf8(accessible_name) : QLatin1String("");
        qmap[QStringLiteral("visible")] = visible;

        gicon = g_icon_new_for_string (icon, nullptr);
        if (gicon) {
            qmap[QStringLiteral("icons")] = QStringList() << iconUri(gicon);
            g_object_unref (gicon);
        }

        if (label) g_free(label);
        if (icon) g_free(icon);
        if (accessible_name) g_free(accessible_name);

        return QVariant::fromValue(qmap);
    }
    return ActionStateParser::toQVariant(state);
}


RootStateObject::RootStateObject(QObject* parent)
    : QObject(parent)
{
}

QString RootStateObject::title() const
{
    if (!valid()) return QString();

    return m_currentState.value(QStringLiteral("title"), QVariant::fromValue(QString())).toString();
}

QString RootStateObject::leftLabel() const
{
    if (!valid()) return QString();

    return m_currentState.value(QStringLiteral("pre-label"), QVariant::fromValue(QString())).toString();
}

QString RootStateObject::rightLabel() const
{
    if (!valid()) return QString();

    return m_currentState.value(QStringLiteral("label"), QVariant::fromValue(QString())).toString();
}

QStringList RootStateObject::icons() const
{
    if (!valid()) return QStringList();

    return m_currentState.value(QStringLiteral("icons"), QVariant::fromValue(QStringList())).toStringList();
}

QString RootStateObject::accessibleName() const
{
    if (!valid()) return QString();

    return m_currentState.value(QStringLiteral("accessible-desc"), QVariant::fromValue(QString())).toString();
}

bool RootStateObject::indicatorVisible() const
{
    if (!valid()) return false;

    return m_currentState.value(QStringLiteral("visible"), QVariant::fromValue(true)).toBool();
}

void RootStateObject::setCurrentState(const QVariantMap& newState)
{
    QString oldTitle = title();
    QString oldLeftLabel = leftLabel();
    QString oldRightLabel = rightLabel();
    QStringList oldIcons = icons();
    QString oldAccessibleName = accessibleName();
    bool oldIndicatorVisible = indicatorVisible();

    if (m_currentState != newState) {
        m_currentState = newState;
        Q_EMIT updated();

        if (oldTitle != title()) Q_EMIT titleChanged();
        if (oldLeftLabel != leftLabel()) Q_EMIT leftLabelChanged();
        if (oldRightLabel != rightLabel()) Q_EMIT rightLabelChanged();
        if (oldIcons != icons()) Q_EMIT iconsChanged();
        if (oldAccessibleName != accessibleName()) Q_EMIT accessibleNameChanged();
        if (oldIndicatorVisible != indicatorVisible()) Q_EMIT indicatorVisibleChanged();
    }
}
