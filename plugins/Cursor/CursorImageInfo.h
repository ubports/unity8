/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#ifndef CURSOR_IMAGE_INFO_H
#define CURSOR_IMAGE_INFO_H

#include "CursorImageProvider.h"

#include <QObject>
#include <QString>
#include <QUrl>

class CursorImageInfo : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString themeName READ themeName WRITE setThemeName NOTIFY themeNameChanged)
    Q_PROPERTY(QString cursorName READ cursorName WRITE setCursorName NOTIFY cursorNameChanged)
    Q_PROPERTY(qreal cursorHeight READ cursorHeight WRITE setCursorHeight NOTIFY cursorHeightChanged)

    Q_PROPERTY(QPoint hotspot READ hotspot NOTIFY hotspotChanged)
    Q_PROPERTY(qreal frameWidth READ frameWidth NOTIFY frameWidthChanged)
    Q_PROPERTY(qreal frameHeight READ frameHeight NOTIFY frameHeightChanged)
    Q_PROPERTY(int frameCount READ frameCount NOTIFY frameCountChanged)
    Q_PROPERTY(int frameDuration READ frameDuration NOTIFY frameDurationChanged)
    Q_PROPERTY(QUrl imageSource READ imageSource NOTIFY imageSourceChanged)

public:
    CursorImageInfo(QObject *parent = nullptr);

    QString themeName() const { return m_themeName; }
    void setThemeName(const QString &);

    QString cursorName() const { return m_cursorName; }
    void setCursorName(const QString &);

    qreal cursorHeight() const { return m_cursorHeight; }
    void setCursorHeight(qreal);

    QPoint hotspot() const;
    qreal frameWidth() const;
    qreal frameHeight() const;
    int frameCount() const;
    int frameDuration() const;
    QUrl imageSource() const;

Q_SIGNALS:
    void themeNameChanged();
    void cursorNameChanged();
    void cursorHeightChanged();
    void hotspotChanged();
    void frameWidthChanged();
    void frameHeightChanged();
    void frameCountChanged();
    void frameDurationChanged();
    void imageSourceChanged();

private Q_SLOTS:
    void update();

private:
    QString m_themeName;
    QString m_cursorName;
    qreal m_cursorHeight{0};

    CursorImage *m_cursorImage{nullptr};
};

#endif // CURSOR_IMAGE_INFO_H
