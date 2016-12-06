/*
 * Copyright (C) 2016 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <QDBusMetaType>
#include <QDebug>

#define GNOME_DESKTOP_USE_UNSTABLE_API
#include <libgnome-desktop/gnome-xkb-info.h>

#include "keyboardLayoutsModel.h"

typedef QList<QMap<QString, QString>> StringMapList;
Q_DECLARE_METATYPE(StringMapList)

KeyboardLayoutsModel::KeyboardLayoutsModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_roleNames = {
        {LayoutIdRole, "layoutId"},
        {DisplayNameRole, "displayName"},
        {LanguageRole, "language"}
    };

    qDBusRegisterMetaType<StringMapList>();

    buildModel();
    connect(this, &KeyboardLayoutsModel::languageChanged, this, &KeyboardLayoutsModel::updateModel);
}

QString KeyboardLayoutsModel::language() const
{
    return m_language;
}

void KeyboardLayoutsModel::setLanguage(const QString &language)
{
    if (m_language == language)
        return;

    m_language = language;
    Q_EMIT languageChanged(language);
}

static bool compareLayouts(const KeyboardLayoutInfo &layout0, const KeyboardLayoutInfo &layout1)
{
    QString name0(layout0.id);
    QString name1(layout1.id);

    if (name0 == name1) {
        name0 = layout0.displayName;
        name1 = layout1.displayName;

        if (name0 == name1) {
            name0 = layout0.language;
            name1 = layout1.language;
        }
    }

    return QString::localeAwareCompare(name0, name1) < 0;
}

void KeyboardLayoutsModel::buildModel()
{
    GList *sources, *tmp;
    const gchar *display_name;
    const gchar *short_name;
    const gchar *xkb_layout;
    const gchar *xkb_variant;

    GnomeXkbInfo * xkbInfo(gnome_xkb_info_new());

    sources = gnome_xkb_info_get_all_layouts(xkbInfo);

    for (tmp = sources; tmp != NULL; tmp = tmp->next) {
        gboolean result = gnome_xkb_info_get_layout_info(xkbInfo, (const gchar *)tmp->data,
                                                         &display_name, &short_name, &xkb_layout, &xkb_variant);
        if (!result) {
            qWarning() << "Skipping invalid layout";
            continue;
        }

        KeyboardLayoutInfo layout;
        layout.id = QString::fromUtf8((const gchar *)tmp->data);
        layout.language = QString::fromUtf8(short_name);
        layout.displayName = QString::fromUtf8(display_name);

        m_db.append(layout);
    }
    g_list_free(sources);
    g_object_unref(xkbInfo);

    std::sort(m_db.begin(), m_db.end(), compareLayouts);
}

void KeyboardLayoutsModel::updateModel()
{
    beginResetModel();
    m_layouts.clear();

    const QString lang = m_language.section("_", 0, 0);
    const QString country = m_language.section("_", 1, 1).toLower();

    Q_FOREACH(const KeyboardLayoutInfo & info, m_db) {
        const QString kbdCountry = info.id.section("+", 0, 0);
        if (info.language == lang &&                                           // filter by language
                (kbdCountry.startsWith(country) || kbdCountry.length() > 2)) { // and by known country, also insert anything that doesn't match the country
            m_layouts.append(info);
        }
    }

    std::sort(m_layouts.begin(), m_layouts.end(), compareLayouts);
    endResetModel();
}

int KeyboardLayoutsModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_layouts.count();
}

QVariant KeyboardLayoutsModel::data(const QModelIndex &index, int role) const
{
    const int row = index.row();

    if (row >= m_layouts.count()) {
        qWarning() << Q_FUNC_INFO << "index out of bounds";
        return QVariant();
    }

    const KeyboardLayoutInfo &layout = m_layouts.at(row);

    switch (role) {
    case Qt::DisplayRole:
    case DisplayNameRole:
        return layout.displayName;
    case LayoutIdRole:
        return layout.id;
    case LanguageRole:
        return layout.language;
    default: {
        qWarning() << Q_FUNC_INFO << "unsupported data role";
        return QVariant();
    }
    }
}

QHash<int, QByteArray> KeyboardLayoutsModel::roleNames() const
{
    return m_roleNames;
}
