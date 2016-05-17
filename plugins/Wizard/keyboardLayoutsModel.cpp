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

#include "keyboardLayoutsModel.h"

typedef QList<QMap<QString, QString>> StringMapList;
Q_DECLARE_METATYPE(StringMapList)

struct KeyboardLayoutInfo {
    QString id;
    QString displayName;
    QString shortName; // language
    QString layoutAndVariant;
};

KeyboardLayoutsModel::KeyboardLayoutsModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_roleNames = {
        {LayoutIdRole, "layoutId"},
        {DisplayNameRole, "displayName"},
        {ShortNameRole, "shortName"},
        {LayoutAndVariantRole, "layoutAndVariant"}
    };

    qDBusRegisterMetaType<StringMapList>();
    m_xkbInfo = gnome_xkb_info_new();

    connect(this, &KeyboardLayoutsModel::languageChanged, this, &KeyboardLayoutsModel::buildModel);
    buildModel();
}

KeyboardLayoutsModel::~KeyboardLayoutsModel()
{
    if (m_xkbInfo != nullptr) {
        g_object_unref(m_xkbInfo);
    }
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
    QString name0(layout0.displayName);
    QString name1(layout1.displayName);

    if (name0 == name1) {
        name0 = layout0.shortName;
        name1 = layout1.shortName;

        if (name0 == name1) {
            name0 = layout0.id;
            name1 = layout1.id;
        }
    }

    return QString::localeAwareCompare(name0, name1) < 0;
}

void KeyboardLayoutsModel::buildModel()
{
    beginResetModel();


    GList *sources, *tmp;
    const gchar *display_name;
    const gchar *short_name;
    const gchar *xkb_layout;
    const gchar *xkb_variant;

    if (m_language.isEmpty()) {
        sources = gnome_xkb_info_get_all_layouts(m_xkbInfo);
    } else {
        sources = gnome_xkb_info_get_layouts_for_language(m_xkbInfo, m_language.toUtf8().constData());
    }

    m_layouts.clear();
    m_layouts.reserve(g_list_length(sources));

    qDebug() << "!!! Got" << m_layouts.count() << "layouts";

    for (tmp = sources; tmp != NULL; tmp = tmp->next) {
        gboolean result = gnome_xkb_info_get_layout_info(m_xkbInfo, (const gchar *)tmp->data,
                                                         &display_name, &short_name, &xkb_layout, &xkb_variant);
        if (!result) {
            qWarning() << "!!! Skipping invalid layout";
            continue;
        }

        KeyboardLayoutInfo layout;
        layout.id = QString::fromUtf8((const gchar *)tmp->data);
        layout.shortName = QString::fromUtf8(short_name);
        layout.displayName = QString::fromUtf8(display_name);
        layout.layoutAndVariant = QString::fromUtf8(g_strconcat(xkb_layout, "+", xkb_variant, NULL));

        if (!layout.shortName.isEmpty()) {
            qDebug() << "!!! Appending layout with id:" << layout.id;
            m_layouts.append(layout);
        }

    }
    g_list_free(sources);
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

    KeyboardLayoutInfo layout = m_layouts.at(row);

    switch (role) {
    case Qt::DisplayRole:
    case DisplayNameRole:
        return layout.displayName;
    case LayoutIdRole:
        return layout.id;
    case ShortNameRole:
        return layout.shortName;
    case LayoutAndVariantRole:
        return layout.layoutAndVariant;
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
