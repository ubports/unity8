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

#ifndef RESULT_H
#define RESULT_H

// Qt
#include <QObject>
#include <QVariant>

// libunity-core
#include <UnityCore/Preview.h>

class Q_DECL_EXPORT Result : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString uri READ uri CONSTANT)
    Q_PROPERTY(QString iconHint READ iconHint CONSTANT)
    Q_PROPERTY(unsigned categoryIndex READ categoryIndex CONSTANT)
    Q_PROPERTY(unsigned resultType READ resultType CONSTANT)
    Q_PROPERTY(QString mimeType READ mimeType CONSTANT)
    Q_PROPERTY(QString title READ title CONSTANT)
    Q_PROPERTY(QString comment READ comment CONSTANT)
    Q_PROPERTY(QString dndUri READ dndUri CONSTANT)
    Q_PROPERTY(QVariant metadata READ metadata CONSTANT)

public:
    Result(QObject *parent = nullptr);
    Result(unity::dash::Preview::Ptr preview, QObject *parent = nullptr);

    void setPreview(unity::dash::Preview::Ptr preview);

    QString uri() const;
    QString iconHint() const;
    unsigned categoryIndex() const;
    unsigned resultType() const;
    QString mimeType() const;
    QString title() const;
    QString comment() const;
    QString dndUri() const;
    QVariant metadata() const;

private:
    /* Keep reference to the original preview to access result attributes via it, rather than keeping copies of them;
       this will save us a bit on copying, especially as UI is mostly interested in just uri.
     */
    unity::dash::Preview::Ptr m_preview;
};

Q_DECLARE_METATYPE(Result *)

#endif
