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

#include "CursorImageProvider.h"

#include <QCursor>
#include <QDebug>
#include <QFile>
#include <QPainter>
#include <QSvgRenderer>

CursorImageProvider *CursorImageProvider::m_instance = nullptr;

/////
// BuiltInCursorImage

BuiltInCursorImage::BuiltInCursorImage()
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

    qimage = QImage(20, 32, QImage::Format_ARGB32);
    QPainter imagePainter(&qimage);

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
}

/////
// CustomCursorImage


CustomCursorImage::CustomCursorImage(const QCursor &cursor)
{
    qimage = cursor.pixmap().toImage();
    hotspot = cursor.hotSpot();
}

/////
// XCursorImage

XCursorImage::XCursorImage(const QString &theme, const QString &file)
    : xcursorImages(nullptr)
{
    // TODO: Consider grid unit value
    //       Hardcoding to a medium size for now
    int preferredCursorHeightPx = 32;

    xcursorImages = XcursorLibraryLoadImages(QFile::encodeName(file), QFile::encodeName(theme),
            preferredCursorHeightPx);
    if (!xcursorImages) {
        return;
    }

    // Just take the first one. It will have multiple images in case of an animated cursor.
    // TODO: Support animated cursors
    if ( xcursorImages->nimage > 0) {
        XcursorImage *xcursorImage = xcursorImages->images[0];

        qimage = QImage((uchar*)xcursorImage->pixels,
                xcursorImage->width, xcursorImage->height, QImage::Format_ARGB32);

        hotspot.setX(xcursorImage->xhot);
        hotspot.setY(xcursorImage->yhot);
    }
}

XCursorImage::~XCursorImage()
{
    XcursorImagesDestroy(xcursorImages);
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

    m_fallbackNames[QLatin1String("closedhand")].append(QLatin1String("grabbing"));
    m_fallbackNames[QLatin1String("closedhand")].append(QLatin1String("dnd-none"));

    m_fallbackNames[QLatin1String("dnd-copy")].append(QLatin1String("dnd-none"));
    m_fallbackNames[QLatin1String("dnd-copy")].append(QLatin1String("grabbing"));
    m_fallbackNames[QLatin1String("dnd-copy")].append(QLatin1String("closedhand"));

    m_fallbackNames[QLatin1String("dnd-move")].append(QLatin1String("dnd-none"));
    m_fallbackNames[QLatin1String("dnd-move")].append(QLatin1String("grabbing"));
    m_fallbackNames[QLatin1String("dnd-move")].append(QLatin1String("closedhand"));

    m_fallbackNames[QLatin1String("dnd-link")].append(QLatin1String("dnd-none"));
    m_fallbackNames[QLatin1String("dnd-link")].append(QLatin1String("grabbing"));
    m_fallbackNames[QLatin1String("dnd-link")].append(QLatin1String("closedhand"));

    m_fallbackNames[QLatin1String("forbidden")].append(QLatin1String("crossed_circle")); // DMZ-White and DMZ-Black themes
    m_fallbackNames[QLatin1String("forbidden")].append(QLatin1String("not-allowed"));
    m_fallbackNames[QLatin1String("forbidden")].append(QLatin1String("circle"));

    m_fallbackNames[QLatin1String("hand")].append(QLatin1String("pointing_hand"));
    m_fallbackNames[QLatin1String("hand")].append(QLatin1String("pointer"));

    m_fallbackNames[QLatin1String("ibeam")].append(QLatin1String("xterm"));
    m_fallbackNames[QLatin1String("ibeam")].append(QLatin1String("text"));

    m_fallbackNames[QLatin1String("left_ptr")].append(QLatin1String("default"));
    m_fallbackNames[QLatin1String("left_ptr")].append(QLatin1String("top_left_arrow"));
    m_fallbackNames[QLatin1String("left_ptr")].append(QLatin1String("left_arrow"));

    m_fallbackNames[QLatin1String("left_ptr_watch")].append(QLatin1String("half-busy"));
    m_fallbackNames[QLatin1String("left_ptr_watch")].append(QLatin1String("progress"));

    m_fallbackNames[QLatin1String("size_bdiag")].append(QLatin1String("fd_double_arrow"));
    m_fallbackNames[QLatin1String("size_bdiag")].append(QLatin1String("nesw-resize"));

    m_fallbackNames[QLatin1String("size_fdiag")].append(QLatin1String("bd_double_arrow")); // DMZ-White and DMZ-Black themes
    m_fallbackNames[QLatin1String("size_fdiag")].append(QLatin1String("nwse-resize"));

    m_fallbackNames[QLatin1String("size_hor")].append(QLatin1String("sb_h_double_arrow")); // DMZ-White and DMZ-Black themes
    m_fallbackNames[QLatin1String("size_hor")].append(QLatin1String("ew-resize"));
    m_fallbackNames[QLatin1String("size_hor")].append(QLatin1String("h_double_arrow"));

    m_fallbackNames[QLatin1String("size_ver")].append(QLatin1String("sb_v_double_arrow")); // DMZ-White and DMZ-Black themes
    m_fallbackNames[QLatin1String("size_ver")].append(QLatin1String("ns-resize"));
    m_fallbackNames[QLatin1String("size_ver")].append(QLatin1String("v_double_arrow"));

    m_fallbackNames[QLatin1String("split_h")].append(QLatin1String("sb_h_double_arrow")); // DMZ-White and DMZ-Black themes
    m_fallbackNames[QLatin1String("split_h")].append(QLatin1String("col-resize"));

    m_fallbackNames[QLatin1String("split_v")].append(QLatin1String("sb_v_double_arrow")); // DMZ-White and DMZ-Black themes
    m_fallbackNames[QLatin1String("split_v")].append(QLatin1String("row-resize"));

    m_fallbackNames[QLatin1String("up_arrow")].append(QLatin1String("sb_up_arrow")); // DMZ-White and DMZ-Black themes

    m_fallbackNames[QLatin1String("watch")].append(QLatin1String("wait"));

    m_fallbackNames[QLatin1String("whats_this")].append(QLatin1String("left_ptr_help"));
    m_fallbackNames[QLatin1String("whats_this")].append(QLatin1String("help"));
    m_fallbackNames[QLatin1String("whats_this")].append(QLatin1String("question_arrow"));

    m_fallbackNames[QLatin1String("xterm")].append(QLatin1String("ibeam"));
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

QImage CursorImageProvider::requestImage(const QString &cursorThemeAndName, QSize *size, const QSize & /*requestedSize*/)
{
    CursorImage *cursorImage = fetchCursor(cursorThemeAndName);
    size->setWidth(cursorImage->qimage.width());
    size->setHeight(cursorImage->qimage.height());

    return cursorImage->qimage;
}

QPoint CursorImageProvider::hotspot(const QString &themeName, const QString &cursorName)
{
    CursorImage *cursorImage = fetchCursor(themeName, cursorName);
    if (cursorImage) {
        return cursorImage->hotspot;
    } else {
        return QPoint(0,0);
    }
}

CursorImage *CursorImageProvider::fetchCursor(const QString &cursorThemeAndName)
{
    QString themeName;
    QString cursorName;
    {
        QStringList themeAndNameList = cursorThemeAndName.split("/");
        if (themeAndNameList.size() != 2) {
            return nullptr;
        }
        themeName = themeAndNameList[0];
        cursorName = themeAndNameList[1];
    }

    return fetchCursor(themeName, cursorName);
}

CursorImage *CursorImageProvider::fetchCursor(const QString &themeName, const QString &cursorName)
{
    CursorImage *cursorImage = fetchCursorHelper(themeName, cursorName);

    // Try some fallbacks
    if (cursorImage->qimage.isNull()) {
        if (m_fallbackNames.contains(cursorName)) {
            const QStringList &fallbackNames = m_fallbackNames[cursorName];
            int i = 0;
            while (cursorImage->qimage.isNull() && i < fallbackNames.count()) {
                qDebug().nospace() << "CursorImageProvider: "<< cursorName <<" not found, trying " << fallbackNames.at(i);
                cursorImage = fetchCursorHelper(themeName, fallbackNames.at(i));
                ++i;
            }
        }
    }

    // if it all fails, there must be at least a left_ptr
    if (cursorImage->qimage.isNull() && cursorName != "left_ptr") {
        qDebug() << "CursorImageProvider:" << cursorName
            << "not found (nor its fallbacks, if any). Going for \"left_ptr\" as a last resort.";
        cursorImage = fetchCursorHelper(themeName, "left_ptr");
    }

    if (cursorImage->qimage.isNull()) {
        // finally, go for the built-in cursor
        qWarning() << "CursorImageProvider: couldn't find any cursors. Using the built-in one";
        if (!m_builtInCursorImage) {
            m_builtInCursorImage.reset(new BuiltInCursorImage);
        }
        cursorImage = m_builtInCursorImage.data();
    }

    return cursorImage;
}

CursorImage *CursorImageProvider::fetchCursorHelper(const QString &themeName, const QString &cursorName)
{
    if (cursorName == QLatin1String("blank")) {
        return &m_blankCursorImage;
    } else if (cursorName == QLatin1String("custom")) {
        return m_customCursorImage.data();
    } else {
        QMap<QString, CursorImage*> &themeCursors = m_cursors[themeName];

        if (!themeCursors.contains(cursorName)) {
            themeCursors[cursorName] = new XCursorImage(themeName, cursorName);
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
