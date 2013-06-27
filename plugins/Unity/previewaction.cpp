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

#include "previewaction.h"

PreviewAction::PreviewAction(QObject *parent)
    : QObject(parent)
{
}

void PreviewAction::setUnityAction(unity::dash::Preview::ActionPtr unityAction)
{
    m_unityAction = unityAction;

    Q_EMIT displayNameChanged();
    Q_EMIT iconHintChanged();
    Q_EMIT extraTextChanged();
    Q_EMIT activationUriChanged();
    Q_EMIT layoutHintChanged();
}

QString PreviewAction::id() const
{
    if (m_unityAction)
        return QString::fromStdString(m_unityAction->id);
    return "";
}

QString PreviewAction::displayName() const
{
    if (m_unityAction)
        return QString::fromStdString(m_unityAction->display_name);
    return "";
}

QString PreviewAction::iconHint() const
{
    if (m_unityAction)
        return QString::fromStdString(m_unityAction->icon_hint);
    return "";
}

QString PreviewAction::extraText() const
{
    if (m_unityAction)
        return QString::fromStdString(m_unityAction->extra_text);
    return "";
}

QString PreviewAction::activationUri() const
{
    if (m_unityAction)
        return QString::fromStdString(m_unityAction->activation_uri);
    return "";
}

LayoutHint PreviewAction::layoutHint() const
{
    if (m_unityAction)
        return static_cast<LayoutHint>(m_unityAction->layout_hint);
    return LayoutHint::None;
}
