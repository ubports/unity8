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
    QPoint hotspot;
};

class XCursorImage : public CursorImage {
public:
    XCursorImage(const QString &theme, const QString &file);
    virtual ~XCursorImage();

    XcursorImages *xcursorImages;
};

class BuiltInCursorImage : public CursorImage {
public:
    BuiltInCursorImage();
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


    QImage requestImage(const QString &cursorName, QSize *size, const QSize &requestedSize) override;

    QPoint hotspot(const QString &themeName, const QString &cursorName);

    void setCustomCursor(const QCursor &customCursor);

private:
    CursorImage *fetchCursor(const QString &cursorThemeAndName);
    CursorImage *fetchCursor(const QString &themeName, const QString &cursorName);
    CursorImage *fetchCursorHelper(const QString &themeName, const QString &cursorName);

    // themeName -> (cursorName -> cursorImage)
    QMap<QString, QMap<QString, CursorImage*> > m_cursors;

    QScopedPointer<CursorImage> m_builtInCursorImage;
    BlankCursorImage m_blankCursorImage;
    QScopedPointer<CursorImage> m_customCursorImage;

    QMap<QString, QStringList> m_fallbackNames;

    static CursorImageProvider *m_instance;
};

#endif // CURSORIMAGEPROVIDER_H
