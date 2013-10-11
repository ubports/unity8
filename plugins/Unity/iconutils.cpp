/*
 * Copyright (C) 2013 Canonical, Ltd.
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
 *
 * Authors:
 *  Michal Hruby <michal.hruby@canonical.com>
 */

#include <QStringList>
#include <QUrl>

#include <gio/gio.h>
#include "iconutils.h"

#define BASE_THEME_ICON_URI "image://theme/"
#define BASE_THUMBNAILER_URI "image://thumbnailer/"
#define BASE_ALBUMART_URI "image://albumart/"

QString gIconToDeclarativeImageProviderString(QString const &giconString)
{
    if (giconString.isEmpty()) return giconString;

    if (giconString.startsWith('/') || giconString.startsWith(QLatin1String("http")) ||
            giconString.startsWith(QLatin1String("file:")) || giconString.startsWith(QLatin1String("image:"))) {
        return giconString;
    }

    if (!giconString.startsWith(QLatin1String(". "))) {
        // must be a themed icon
        QString themedIcon(BASE_THEME_ICON_URI);
        themedIcon.append(giconString);
        return themedIcon;
    }

    // special case annotated icon
    if (giconString.startsWith(QLatin1String(". UnityProtocolAnnotatedIcon "))) {
        QString annotatedIcon;
        QString serializedData(QUrl::fromPercentEncoding(giconString.mid(29).toUtf8()));
        GVariant *variant = g_variant_parse(G_VARIANT_TYPE_VARDICT, serializedData.toUtf8().constData(), NULL, NULL, NULL);
        gchar *baseUri;
        if (variant != NULL && g_variant_lookup(variant, "base-icon", "&s", &baseUri)) {
            annotatedIcon = gIconToDeclarativeImageProviderString(QString(baseUri));
            // FIXME: enclose in image://annotated/... once unity supports that
        }
        if (variant != NULL) g_variant_unref(variant);

        return annotatedIcon;
    }

    // handle real gicon strings
    QString result;
    GError *error = NULL;
    GIcon *icon = g_icon_new_for_string(giconString.toLocal8Bit().constData(), &error);
    if (error != NULL || icon == NULL) {
        qWarning("Unable to deserialize icon: %s", giconString.toLocal8Bit().constData());
        g_clear_error(&error);
        return result;
    }

    if (G_IS_THEMED_ICON(icon)) {
        QString themedIcon(BASE_THEME_ICON_URI);
        QStringList list;
        const char* const *iconNames = g_themed_icon_get_names(G_THEMED_ICON(icon));
        if (iconNames != NULL) {
            for (const char * const *iter = iconNames; *iter != NULL; ++iter) {
                list << QLatin1String(*iter);
            }
        }
        themedIcon.append(list.join(QString(",")));
        result = themedIcon;
    } else if (G_IS_FILE_ICON(icon)) {
        GFile *file = g_file_icon_get_file(G_FILE_ICON(icon));
        gchar *uri = g_file_get_uri(file);
        QString iconUri(uri);
        g_free(uri);
        result = iconUri;
    }

    g_object_unref(icon);

    return result;
}

QString uriToThumbnailerProviderString(QString const &uri, QString const &mimetype, QVariantHash const &metadata)
{
    if (uri.startsWith(QLatin1String("file:///"))) {
        bool isAudio = mimetype.startsWith(QLatin1String("audio/"));
        QString thumbnailerUri;
        if (isAudio) {
            thumbnailerUri = BASE_ALBUMART_URI;
            if (metadata.contains("content")) {
                QVariantHash contentHash = metadata["content"].toHash();
                if (contentHash.contains("content")) { // nested content in Home?
                    contentHash = contentHash["content"].toHash();
                }
                if (contentHash.contains("album") &&
                    contentHash.contains("artist")) {
                    const QString album = contentHash["album"].toString();
                    const QString artist = contentHash["artist"].toString();
                    thumbnailerUri.append(QUrl::toPercentEncoding(artist));
                    thumbnailerUri.append("/");
                    thumbnailerUri.append(QUrl::toPercentEncoding(album));
                }
            }
        } else {
            thumbnailerUri = BASE_THUMBNAILER_URI;
            thumbnailerUri.append(uri.midRef(7));
        }
        return thumbnailerUri;
    }

    return QString::null;
}
