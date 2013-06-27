/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Pawel Stolowski <pawel.stolowski@canonical.com>
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

// local
#include "preview.h"
#include "previewaction.h"
#include "previewinfohint.h"
#include "genericpreview.h"
#include "applicationpreview.h"
#include "moviepreview.h"
#include "musicpreview.h"
#include "variantutils.h"

// Qt
#include <QDebug>

#include <UnityCore/GenericPreview.h>
#include <UnityCore/ApplicationPreview.h>
#include <UnityCore/MoviePreview.h>
#include <UnityCore/MusicPreview.h>

Preview::Preview(QObject *parent):
    QObject(parent)
{
}

QString Preview::rendererName() const
{
    if (m_unityPreview) {
        return QString::fromStdString(m_unityPreview->renderer_name());
    } else {
        qWarning() << "Preview not set";
    }
    return "";
}

QString Preview::title() const
{
    if (m_unityPreview) {
        return QString::fromStdString(m_unityPreview->title());
    } else {
        qWarning() << "Preview not set";
    }
    return "";
}

QString Preview::subtitle () const
{
    if (m_unityPreview) {
        return QString::fromStdString(m_unityPreview->subtitle());
    } else {
        qWarning() << "Preview not set";
    }
    return "";
}

QString Preview::description() const
{
    if (m_unityPreview) {
        return QString::fromStdString(m_unityPreview->description());
    } else {
        qWarning() << "Preview not set";
    }
    return "";
}

QVariant Preview::actions()
{
    QList<QObject *> alist;
    if (m_unityPreview) {
        for (auto unityAction: m_unityPreview->GetActions()) {
            auto action = new PreviewAction(this); // preview is the owner of actions
            action->setUnityAction(unityAction);
            alist.append(action);
        }
    } else {
        qWarning() << "Preview not set";
    }

    return QVariant::fromValue(alist);
}

QVariant Preview::infoHints()
{
    QList<QObject *> hints;
    if (m_unityPreview) {
        for (auto unityInfoHint: m_unityPreview->GetInfoHints()) {
            auto hint = new PreviewInfoHint(this); // preview is the owner of hints
            hint->setUnityInfoHint(unityInfoHint);
            hints.append(hint);
        }
    } else {
        qWarning() << "Preview not set";
    }

    return QVariant::fromValue(hints);
}

QString Preview::image() const
{
    if (m_unityPreview) {
        return QString::fromUtf8(g_icon_to_string(m_unityPreview->image()));
    } else {
        qWarning() << "Preview not set";
    }
    return QString::null;
}

QString Preview::imageSourceUri() const
{
    if (m_unityPreview) {
        return QString::fromStdString(m_unityPreview->image_source_uri());
    } else {
        qWarning() << "Preview not set";
    }
    return QString::null;
}

Preview* Preview::newFromUnityPreview(unity::dash::Preview::Ptr unityPreview)
{
    Preview* preview = nullptr;

    if (typeid(*unityPreview) == typeid(unity::dash::GenericPreview)) {
        preview = new GenericPreview();
    }
    else if (typeid(*unityPreview) == typeid(unity::dash::MusicPreview)) {
        preview = new MusicPreview();
    }
    else if (typeid(*unityPreview) == typeid(unity::dash::MoviePreview)) {
        preview = new MoviePreview();
    }
    else if (typeid(*unityPreview) == typeid(unity::dash::ApplicationPreview)) {
        preview = new ApplicationPreview();
    } else {
        qWarning() << "Unknown preview type: " << typeid(*unityPreview).name();
        preview = new GenericPreview();
    }
    
    preview->Preview::setUnityPreview(unityPreview);
    preview->setUnityPreview(unityPreview);

    return preview;
}

void Preview::setUnityPreview(unity::dash::Preview::Ptr unityPreview)
{
    m_unityPreview = unityPreview;

    Q_EMIT rendererNameChanged();
    Q_EMIT titleChanged();
    Q_EMIT subtitleChanged();
    Q_EMIT descriptionChanged();
    Q_EMIT actionsChanged();
    Q_EMIT infoHintsChanged();
    Q_EMIT imageChanged();
    Q_EMIT imageSourceUriChanged();
}

void Preview::execute(const QString& actionId, const QHash<QString, QVariant>& hints)
{
    if (m_unityPreview) {
        auto unityHints = convertToHintsMap(hints);
        m_unityPreview->PerformAction(actionId.toStdString(), unityHints);
    } else {
        qWarning() << "Preview not set";
    }
}

