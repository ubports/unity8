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
#include "socialpreview.h"
#include "iconutils.h"
#include "variantutils.h"

// Qt
#include <QDebug>
#include <QtAlgorithms>

#include <UnityCore/GenericPreview.h>
#include <UnityCore/ApplicationPreview.h>
#include <UnityCore/MoviePreview.h>
#include <UnityCore/MusicPreview.h>
#include <UnityCore/SocialPreview.h>

Preview::Preview(QObject *parent):
    QObject(parent),
    m_unityPreview(nullptr),
    m_result(new Result(this))
{
}

QString Preview::rendererName() const
{
    if (m_unityPreview) {
        return QString::fromStdString(m_unityPreview->renderer_name());
    } else {
        qWarning() << "Preview not set";
    }
    return QString();
}

QString Preview::title() const
{
    if (m_unityPreview) {
        return QString::fromStdString(m_unityPreview->title());
    } else {
        qWarning() << "Preview not set";
    }
    return QString();
}

QString Preview::subtitle () const
{
    if (m_unityPreview) {
        return QString::fromStdString(m_unityPreview->subtitle());
    } else {
        qWarning() << "Preview not set";
    }
    return QString();
}

QString Preview::description() const
{
    if (m_unityPreview) {
        return QString::fromStdString(m_unityPreview->description());
    } else {
        qWarning() << "Preview not set";
    }
    return QString();
}

QVariant Preview::actions()
{
    return QVariant::fromValue(m_actions);
}

QVariant Preview::infoHints()
{
    return QVariant::fromValue(m_infoHints);
}

QVariantMap Preview::infoHintsHash() const
{
    return m_infoHintsHash;
}

QString Preview::image() const
{
    if (m_unityPreview) {
        auto giconString = g_icon_to_string(m_unityPreview->image());
        QString result(gIconToDeclarativeImageProviderString(QString::fromUtf8(giconString)));
        g_free(giconString);
        return result;
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

Result* Preview::result() const
{
    return m_result;
}

Preview* Preview::newFromUnityPreview(unity::dash::Preview::Ptr unityPreview)
{
    Preview* preview = nullptr;

    if (dynamic_cast<unity::dash::GenericPreview *>(unityPreview.get()) != nullptr) {
        preview = new GenericPreview();
    } else if (dynamic_cast<unity::dash::MusicPreview *>(unityPreview.get()) != nullptr) {
        preview = new MusicPreview();
    } else if (dynamic_cast<unity::dash::MoviePreview *>(unityPreview.get()) != nullptr) {
        preview = new MoviePreview();
    } else if (dynamic_cast<unity::dash::ApplicationPreview *>(unityPreview.get()) != nullptr) {
        preview = new ApplicationPreview();
    } else if (dynamic_cast<unity::dash::SocialPreview *>(unityPreview.get()) != nullptr) {
        preview = new SocialPreview();
    } else {
        qWarning() << "Unknown preview type: " << typeid(*unityPreview).name();
        preview = new GenericPreview();
    }

    preview->setUnityPreviewBase(unityPreview);
    preview->setUnityPreview(unityPreview);

    return preview;
}

void Preview::setUnityPreviewBase(unity::dash::Preview::Ptr unityPreview)
{
    m_unityPreview = unityPreview;
    m_result->setPreview(unityPreview);

    qDeleteAll(m_infoHints);
    m_infoHints.clear();
    m_infoHintsHash.clear();
    qDeleteAll(m_actions);
    m_actions.clear();

    for (auto unityInfoHint: m_unityPreview->GetInfoHints()) {
        auto hint = new PreviewInfoHint(this);
        hint->setUnityInfoHint(unityInfoHint);
        m_infoHints.append(hint);
        m_infoHintsHash[hint->id()] = QVariant::fromValue(hint);
    }

    for (auto unityAction: m_unityPreview->GetActions()) {
        auto action = new PreviewAction(this);
        action->setUnityAction(unityAction);
        m_actions.append(action);
    }
}

void Preview::setUnityPreview(unity::dash::Preview::Ptr /* unityPreview */)
{
    // default implementation does nothing
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
