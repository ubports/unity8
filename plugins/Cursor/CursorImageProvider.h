/*
 * Copyright (C) 2015 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef CURSORIMAGEPROVIDER_H
#define CURSORIMAGEPROVIDER_H

#include <QQuickImageProvider>
#include <QScopedPointer>

// xcursor static lib
extern "C"
{
#include <xcursor.h>
}

class CursorImage {
public:
    virtual ~CursorImage() {}

    QImage qimage;

    // TODO: consider if there's a need to animate the hotspot
    // ie, if there's a need to make it an array of points, one for each frame.
    // Maybe no single xcursor (or at least the ones we know of or use)
    // vary its hotspot position through its animation.
    QPoint hotspot;

    int frameWidth{0};
    int frameHeight{0};
    int frameCount{1};
    int frameDuration{40};

    // Requested height when creating this cursor.
    int requestedHeight{0};
};

class XCursorImage : public CursorImage {
public:
    XCursorImage(const QString &theme, const QString &file, int preferredCursorHeightPx);
    virtual ~XCursorImage();
};

class BuiltInCursorImage : public CursorImage {
public:
    BuiltInCursorImage(int cursorHeight);
};

class BlankCursorImage  : public CursorImage {
public:
    BlankCursorImage();
};

class CustomCursorImage  : public CursorImage {
public:
    CustomCursorImage(const QCursor &cursor);
};

class CursorImageProvider : public QQuickImageProvider
{
public:
    CursorImageProvider();
    virtual ~CursorImageProvider();

    static CursorImageProvider *instance() { return m_instance; }


    QImage requestImage(const QString &cursorThemeAndNameAndHeight, QSize *size, const QSize &requestedSize) override;

    CursorImage *fetchCursor(const QString &themeName, const QString &cursorName, int cursorHeight);

    void setCustomCursor(const QCursor &customCursor);

private:
    CursorImage *fetchCursor(const QString &cursorThemeAndNameAndHeight);
    CursorImage *fetchCursorHelper(const QString &themeName, const QString &cursorName, int cursorHeight);

    // themeName -> (cursorName -> cursorImage)
    // TODO: discard old, unused, cursors
    QMap<QString, QMap<QString, CursorImage*> > m_cursors;

    QScopedPointer<CursorImage> m_builtInCursorImage;
    BlankCursorImage m_blankCursorImage;
    QScopedPointer<CursorImage> m_customCursorImage;

    QMap<QString, QStringList> m_fallbackNames;

    static CursorImageProvider *m_instance;
};

#endif // CURSORIMAGEPROVIDER_H
