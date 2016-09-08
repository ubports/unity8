/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
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

#include "CursorImageProvider.h"

#include <QCursor>
#include <QDebug>
#include <QFile>
#include <QPainter>
#include <QSvgRenderer>

CursorImageProvider *CursorImageProvider::m_instance = nullptr;

/////
// BuiltInCursorImage

BuiltInCursorImage::BuiltInCursorImage(int cursorHeight)
{
    const char *svgString =
        "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>"
         "<svg"
         "   xmlns:dc=\"http://purl.org/dc/elements/1.1/\""
         "   xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\""
         "   xmlns:svg=\"http://www.w3.org/2000/svg\""
         "   xmlns=\"http://www.w3.org/2000/svg\""
         "   version=\"1.1\">"
         "    <path"
         "       style=\"fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:40;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1\""
         "       d=\"M 20.504,50.94931 460.42533,518.14486 266.47603,515.61948 366.48114,719.16522 274.05218,770.68296 172.53185,559.56112 20.504,716.13476 Z\" />"
         "</svg>";

    // NB: Original image dimension is 20x32. Ensure aspect ratio is kept
    qimage = QImage((20./32.)*cursorHeight, cursorHeight, QImage::Format_ARGB32);
    qimage.fill(Qt::transparent);
    QPainter imagePainter(&qimage);

    frameWidth = qimage.width();
    frameHeight = qimage.height();
    requestedHeight = cursorHeight;

    QSvgRenderer *svgRenderer = new QSvgRenderer(QByteArray(svgString));
    svgRenderer->render(&imagePainter);
    delete svgRenderer;
}

/////
// BlankCursorImage


BlankCursorImage::BlankCursorImage()
{
    qimage = QImage(1, 1, QImage::Format_ARGB32);
    qimage.fill(Qt::transparent);
    frameWidth = qimage.width();
    frameHeight = qimage.height();
}

/////
// CustomCursorImage


CustomCursorImage::CustomCursorImage(const QCursor &cursor)
{
    qimage = cursor.pixmap().toImage();
    hotspot = cursor.hotSpot();
    frameWidth = qimage.width();
    frameHeight = qimage.height();
}

/////
// XCursorImage

XCursorImage::XCursorImage(const QString &theme, const QString &file, int preferredCursorHeightPx)
{
    requestedHeight = preferredCursorHeightPx;

    XcursorImages *xcursorImages = XcursorLibraryLoadImages(QFile::encodeName(file), QFile::encodeName(theme),
            preferredCursorHeightPx);
    if (!xcursorImages || xcursorImages->nimage == 0) {
        return;
    }

    frameCount = xcursorImages->nimage;

    for (int i = 0; i < xcursorImages->nimage; ++i) {
        XcursorImage *xcursorImage = xcursorImages->images[i];
        if (frameWidth <  (int)xcursorImage->width) {
            frameWidth = xcursorImage->width;
        }
        if (frameHeight <  (int)xcursorImage->height) {
            frameHeight = xcursorImage->height;
        }
        if (i == 0) {
            frameDuration = (int)xcursorImage->delay;
        } else {
            if (frameDuration != (int)xcursorImage->delay) {
                qWarning().nospace() << "CursorImageProvider: XCursorImage("<<theme<<","<<file<<") has"
                                        " varying delays in its animation. Animation won't look right.";
            }
        }
    }

    {
        // Assume that the hotspot position does not animate
        XcursorImage *xcursorImage = xcursorImages->images[0];
        hotspot.setX(xcursorImage->xhot);
        hotspot.setY(xcursorImage->yhot);
    }

    // Build the sprite as a single row of frames
    qimage = QImage(frameWidth*frameCount, frameHeight, QImage::Format_ARGB32);
    qimage.fill(Qt::transparent);

    {
        QPainter painter(&qimage);

        for (int i = 0; i < xcursorImages->nimage; ++i) {
            XcursorImage *xcursorImage = xcursorImages->images[i];

            auto frameImage = QImage((uchar*)xcursorImage->pixels,
                    xcursorImage->width, xcursorImage->height, QImage::Format_ARGB32);

            painter.drawImage(QPoint(i*frameWidth, 0), frameImage);
        }
    }

    XcursorImagesDestroy(xcursorImages);
}

XCursorImage::~XCursorImage()
{
}

/////
// CursorImageProvider

CursorImageProvider::CursorImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Image)
{
    if (m_instance) {
        qFatal("Cannot have multiple CursorImageProvider instances");
    }
    m_instance = this;

    m_fallbackNames[QStringLiteral("closedhand")].append(QStringLiteral("grabbing"));
    m_fallbackNames[QStringLiteral("closedhand")].append(QStringLiteral("dnd-none"));

    m_fallbackNames[QStringLiteral("dnd-copy")].append(QStringLiteral("dnd-none"));
    m_fallbackNames[QStringLiteral("dnd-copy")].append(QStringLiteral("grabbing"));
    m_fallbackNames[QStringLiteral("dnd-copy")].append(QStringLiteral("closedhand"));

    m_fallbackNames[QStringLiteral("dnd-move")].append(QStringLiteral("dnd-none"));
    m_fallbackNames[QStringLiteral("dnd-move")].append(QStringLiteral("grabbing"));
    m_fallbackNames[QStringLiteral("dnd-move")].append(QStringLiteral("closedhand"));

    m_fallbackNames[QStringLiteral("dnd-link")].append(QStringLiteral("dnd-none"));
    m_fallbackNames[QStringLiteral("dnd-link")].append(QStringLiteral("grabbing"));
    m_fallbackNames[QStringLiteral("dnd-link")].append(QStringLiteral("closedhand"));

    m_fallbackNames[QStringLiteral("forbidden")].append(QStringLiteral("crossed_circle")); // DMZ-White and DMZ-Black themes
    m_fallbackNames[QStringLiteral("forbidden")].append(QStringLiteral("not-allowed"));
    m_fallbackNames[QStringLiteral("forbidden")].append(QStringLiteral("circle"));

    m_fallbackNames[QStringLiteral("hand")].append(QStringLiteral("pointing_hand"));
    m_fallbackNames[QStringLiteral("hand")].append(QStringLiteral("pointer"));

    m_fallbackNames[QStringLiteral("ibeam")].append(QStringLiteral("xterm"));
    m_fallbackNames[QStringLiteral("ibeam")].append(QStringLiteral("text"));

    m_fallbackNames[QStringLiteral("left_ptr")].append(QStringLiteral("default"));
    m_fallbackNames[QStringLiteral("left_ptr")].append(QStringLiteral("top_left_arrow"));
    m_fallbackNames[QStringLiteral("left_ptr")].append(QStringLiteral("left_arrow"));

    m_fallbackNames[QStringLiteral("left_ptr_watch")].append(QStringLiteral("half-busy"));
    m_fallbackNames[QStringLiteral("left_ptr_watch")].append(QStringLiteral("progress"));

    m_fallbackNames[QStringLiteral("size_bdiag")].append(QStringLiteral("fd_double_arrow"));
    m_fallbackNames[QStringLiteral("size_bdiag")].append(QStringLiteral("nesw-resize"));

    m_fallbackNames[QStringLiteral("size_fdiag")].append(QStringLiteral("bd_double_arrow")); // DMZ-White and DMZ-Black themes
    m_fallbackNames[QStringLiteral("size_fdiag")].append(QStringLiteral("nwse-resize"));

    m_fallbackNames[QStringLiteral("size_hor")].append(QStringLiteral("sb_h_double_arrow")); // DMZ-White and DMZ-Black themes
    m_fallbackNames[QStringLiteral("size_hor")].append(QStringLiteral("ew-resize"));
    m_fallbackNames[QStringLiteral("size_hor")].append(QStringLiteral("h_double_arrow"));

    m_fallbackNames[QStringLiteral("size_ver")].append(QStringLiteral("sb_v_double_arrow")); // DMZ-White and DMZ-Black themes
    m_fallbackNames[QStringLiteral("size_ver")].append(QStringLiteral("ns-resize"));
    m_fallbackNames[QStringLiteral("size_ver")].append(QStringLiteral("v_double_arrow"));

    m_fallbackNames[QStringLiteral("split_h")].append(QStringLiteral("sb_h_double_arrow")); // DMZ-White and DMZ-Black themes
    m_fallbackNames[QStringLiteral("split_h")].append(QStringLiteral("col-resize"));

    m_fallbackNames[QStringLiteral("split_v")].append(QStringLiteral("sb_v_double_arrow")); // DMZ-White and DMZ-Black themes
    m_fallbackNames[QStringLiteral("split_v")].append(QStringLiteral("row-resize"));

    m_fallbackNames[QStringLiteral("up_arrow")].append(QStringLiteral("sb_up_arrow")); // DMZ-White and DMZ-Black themes

    m_fallbackNames[QStringLiteral("watch")].append(QStringLiteral("wait"));

    m_fallbackNames[QStringLiteral("whats_this")].append(QStringLiteral("left_ptr_help"));
    m_fallbackNames[QStringLiteral("whats_this")].append(QStringLiteral("help"));
    m_fallbackNames[QStringLiteral("whats_this")].append(QStringLiteral("question_arrow"));

    m_fallbackNames[QStringLiteral("xterm")].append(QStringLiteral("ibeam"));
}

CursorImageProvider::~CursorImageProvider()
{
    {
        QList< QMap<QString, CursorImage*> > cursorList = m_cursors.values();

        for (int i = 0; i < cursorList.count(); ++i) {
            QList<CursorImage*> cursorImageList = cursorList[i].values();
            for (int j = 0; j < cursorImageList.count(); ++j) {
                delete cursorImageList[j];
            }
        }
    }

    m_cursors.clear();
    m_instance = nullptr;
}

QImage CursorImageProvider::requestImage(const QString &cursorThemeAndNameAndHeight, QSize *size, const QSize & /*requestedSize*/)
{
    CursorImage *cursorImage = fetchCursor(cursorThemeAndNameAndHeight);
    size->setWidth(cursorImage->qimage.width());
    size->setHeight(cursorImage->qimage.height());

    return cursorImage->qimage;
}

CursorImage *CursorImageProvider::fetchCursor(const QString &cursorThemeAndNameAndHeight)
{
    QString themeName;
    QString cursorName;
    int cursorHeight;
    {
        QStringList themeAndNameList = cursorThemeAndNameAndHeight.split('/');
        if (themeAndNameList.size() != 3) {
            return nullptr;
        }
        themeName = themeAndNameList[0];
        cursorName = themeAndNameList[1];

        bool ok;
        cursorHeight = themeAndNameList[2].toInt(&ok);
        if (!ok) {
            cursorHeight = 32;
            qWarning().nospace() << "CursorImageProvider: invalid cursor height ("<<themeAndNameList[2]<<")."
                " Falling back to "<<cursorHeight<<" pixels";
        }
    }

    return fetchCursor(themeName, cursorName, cursorHeight);
}

CursorImage *CursorImageProvider::fetchCursor(const QString &themeName, const QString &cursorName, int cursorHeight)
{
    CursorImage *cursorImage = fetchCursorHelper(themeName, cursorName, cursorHeight);

    // Try some fallbacks
    if (cursorImage->qimage.isNull()) {
        if (m_fallbackNames.contains(cursorName)) {
            const QStringList &fallbackNames = m_fallbackNames[cursorName];
            int i = 0;
            while (cursorImage->qimage.isNull() && i < fallbackNames.count()) {
                qDebug().nospace() << "CursorImageProvider: "<< cursorName <<" not found, trying " << fallbackNames.at(i);
                cursorImage = fetchCursorHelper(themeName, fallbackNames.at(i), cursorHeight);
                ++i;
            }
        }
    }

    // if it all fails, there must be at least a left_ptr
    if (cursorImage->qimage.isNull() && cursorName != QLatin1String("left_ptr")) {
        qDebug() << "CursorImageProvider:" << cursorName
            << "not found (nor its fallbacks, if any). Going for \"left_ptr\" as a last resort.";
        cursorImage = fetchCursorHelper(themeName, QStringLiteral("left_ptr"), cursorHeight);
    }

    if (cursorImage->qimage.isNull()) {
        // finally, go for the built-in cursor
        qWarning() << "CursorImageProvider: couldn't find any cursors. Using the built-in one";
        if (!m_builtInCursorImage || m_builtInCursorImage->requestedHeight != cursorHeight) {
            m_builtInCursorImage.reset(new BuiltInCursorImage(cursorHeight));
        }
        cursorImage = m_builtInCursorImage.data();
    }

    return cursorImage;
}

CursorImage *CursorImageProvider::fetchCursorHelper(const QString &themeName, const QString &cursorName, int cursorHeight)
{
    if (cursorName == QLatin1String("blank")) {
        return &m_blankCursorImage;
    } else if (cursorName.startsWith(QLatin1String("custom"))) {
        return m_customCursorImage.data();
    } else {
        QMap<QString, CursorImage*> &themeCursors = m_cursors[themeName];

        if (!themeCursors.contains(cursorName)) {
            themeCursors[cursorName] = new XCursorImage(themeName, cursorName, cursorHeight);
        } else if (themeCursors[cursorName]->requestedHeight != cursorHeight) {
            delete themeCursors.take(cursorName);
            themeCursors[cursorName] = new XCursorImage(themeName, cursorName, cursorHeight);
        }

        return themeCursors[cursorName];
    }
}

void CursorImageProvider::setCustomCursor(const QCursor &customCursor)
{
    if (customCursor.pixmap().isNull()) {
        m_customCursorImage.reset();
    } else {
        m_customCursorImage.reset(new CustomCursorImage(customCursor));
    }
}
