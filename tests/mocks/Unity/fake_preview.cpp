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
 */

#include "fake_preview.h"

Preview::Preview(QObject *parent): QObject(parent)
{
}

QString Preview::rendererName() const
{
    return "foo";
}

QString Preview::title() const
{
    return "Title";
}

QString Preview::subtitle() const
{
    return "Subtitle";
}

QString Preview::description() const
{
    return "Description";
}

QVariant Preview::actions()
{
    return QVariant();
}

QVariant Preview::infoHints()
{
    return QVariant();
}

QVariantMap Preview::infoHintsHash() const
{
    return QVariantMap();
}

QString Preview::image() const
{
    return "";
}

void Preview::execute(const QString& actionId, const QHash<QString, QVariant>& hints)
{
    Q_UNUSED(actionId);
    Q_UNUSED(hints);
}
