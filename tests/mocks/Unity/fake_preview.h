/*
 * Copyright (C) 2013, 2014 Canonical, Ltd.
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

#ifndef FAKE_PREVIEW_H
#define FAKE_PREVIEW_H

// Qt
#include <QObject>
#include <QString>
#include <QMetaType>
#include <QList>
#include <QVariantMap>

class Q_DECL_EXPORT Preview : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString rendererName READ rendererName NOTIFY previewChanged)
    Q_PROPERTY(QString title READ title NOTIFY previewChanged)
    Q_PROPERTY(QString subtitle READ subtitle NOTIFY previewChanged)
    Q_PROPERTY(QString description READ description NOTIFY previewChanged)
    Q_PROPERTY(QVariant actions READ actions NOTIFY previewChanged)
    Q_PROPERTY(QVariant infoHints READ infoHints NOTIFY previewChanged)
    Q_PROPERTY(QVariantMap infoMap READ infoHintsHash NOTIFY previewChanged)
    Q_PROPERTY(QString image READ image NOTIFY previewChanged)

public:
    explicit Preview(const QString &rendererName, QObject *parent = 0);

    QString rendererName() const;
    QString title() const;
    QString subtitle() const;
    QString description() const;
    QVariant actions();
    QVariant infoHints();
    QVariantMap infoHintsHash() const;
    QString image() const;

    Q_INVOKABLE void execute(const QString& actionId, const QHash<QString, QVariant>& hints);

    Q_INVOKABLE void cancelAction();

Q_SIGNALS:
    void previewChanged();

private:
    QString m_rendererName;
};

Q_DECLARE_METATYPE(Preview *)

#endif // FAKE_PREVIEW_H
