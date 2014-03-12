/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Jussi Pakkanen <jussi.pakkanen@canonical.com>
 *          Pawel Stolowski <pawel.stolowski@canonical.com>
*/

#include "albumartprovider.h"
#include <QString>
#include <QNetworkAccessManager>
#include <QEventLoop>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QXmlQuery>
#include <QTemporaryFile>
#include <QBuffer>
#include <QDebug>
#include <QFile>
#include <QStringList>
#include <QByteArray>
#include <QImage>
#include <QUrl>
#include <QUrlQuery>
#include <QtConcurrent>

using namespace std;

const std::string AlbumArtProvider::DEFAULT_ALBUM_ART = "/usr/share/unity/icons/album_missing.png";
const std::string AlbumArtProvider::UNITY_LENS_SCHEMA = "com.canonical.Unity.Lenses";

static QByteArray download(QString url) {
    QScopedPointer<QNetworkAccessManager> am(new QNetworkAccessManager);
    QNetworkReply *reply = am->get(QNetworkRequest(QUrl(url)));
    QEventLoop loop;
    QObject::connect(am.data(), &QNetworkAccessManager::finished, &loop, &QEventLoop::quit);
    loop.exec();

    if (reply->error() != QNetworkReply::NoError) {
        qWarning() << "Error downloading from the network:" << reply->errorString();
        return QByteArray();
    }
    return reply->readAll();
}

AlbumArtProvider::AlbumArtProvider()
    : QQuickImageProvider(QQmlImageProviderBase::Image, QQmlImageProviderBase::ForceAsynchronousImageLoading),
      m_settings(nullptr)
{
    auto schemas = g_settings_list_schemas();
    if (schemas) {
        for (int i = 0; schemas[i]; i++) {
            if (g_strcmp0(schemas[i], UNITY_LENS_SCHEMA.c_str()) == 0) {
                m_settings = g_settings_new(UNITY_LENS_SCHEMA.c_str());
                break;
            }
        }
    }
    if (m_settings == nullptr) {
        qWarning() << "Missing" << QString::fromStdString(UNITY_LENS_SCHEMA) << "schema";
    }
}

AlbumArtProvider::~AlbumArtProvider()
{
    if (m_settings)
        g_object_unref(m_settings);
}

std::string AlbumArtProvider::get_lastfm_url(const albuminfo &ai) {
    QString artist = QString::fromStdString(ai.artist);
    QString album = QString::fromStdString(ai.album);
    // audioscrobbler wants it without any / (as it would break the URL)
    artist.remove('/');
    album.remove('/');

    /// @todo: this is the old API which will probably get axed at some point in the future
    ///        The new 2.0 API requires an API key, but supports JSON output, etc, so switching
    ///        to it should be done ASAP.
    QString request = QString("http://ws.audioscrobbler.com/1.0/album/%1/%2/info.xml").arg(artist)
                                                                                      .arg(album)
                                                                                      .toHtmlEscaped();
    QFuture<QByteArray> future = QtConcurrent::run(download, request);
    QByteArray arr = future.result();
    if(arr.size() == 0) {
        return "";
    }
    QXmlQuery query;
    QBuffer tmp;
    tmp.setData(arr);
    tmp.open(QIODevice::ReadOnly);
    query.bindVariable("reply", &tmp);
    query.setQuery("doc($reply)/album/coverart/large[1]/text()");
    QString image;
    query.evaluateTo(&image);
    image = image.trimmed();

    // return empty if last.fm tries to offer their default
    // fallback artwork
    if (image.contains("catalogue/noimage")) {
        return "";
    }

    return image.toStdString();
}

bool AlbumArtProvider::download_and_store(const std::string &image_url, const std::string &output_file) {
    QString url = QString::fromStdString(image_url);
    QString fileName = QString::fromStdString(output_file);
    QFuture<QByteArray> future = QtConcurrent::run(download, url);
    QByteArray arr = future.result();
    if (arr.size() == 0) {
        return false;
    }
    QFile file(fileName);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        qWarning() << "Could not open file for writing:" << file.errorString();
        return false;
    }
    if (file.write(arr) == -1){
        qWarning() << "Could not write the image:" << file.error();
        return false;
    }

    return true;
}

void AlbumArtProvider::fix_format(const std::string &fname) {
    // MediaArtSpec requires jpg. Convert to it if necessary.
    FILE *f = fopen(fname.c_str(), "r");
    if(!f)
        return;
    unsigned char buf[2];
    fread(buf, 1, 2, f);
    fclose(f);
    if(buf[0] == 0xff && buf[1] == 0xd8) {
        return;
    }
    QImage im(fname.c_str());
    im.save(fname.c_str(), "JPEG");
}

std::string AlbumArtProvider::get_image(const std::string &artist, const std::string &album) {
    albuminfo info;

    info.artist = artist;
    info.album = album;

    if(info.album.empty() || info.artist.empty()) {
        return DEFAULT_ALBUM_ART;
    }
    if(cache.has_art(info.artist, info.album)) {
        // Image may have expired from cache between these two lines.
        // It might expire before we return. C'est la vie.
        return cache.get_art_file(info.artist, info.album);
    }

    if (m_settings != nullptr && g_strcmp0(g_settings_get_string(m_settings, "remote-content-search"), "all") !=0) {
        qDebug() << "Remote content disabled";
        return DEFAULT_ALBUM_ART;
    }

    std::string image_url = get_lastfm_url(info);
    if(image_url.empty()) {
        return DEFAULT_ALBUM_ART;
    }
    QTemporaryFile tempFile;
    tempFile.open();
    tempFile.setAutoRemove(true);
    QString fname = tempFile.fileName();
    std::string tmpname = fname.toUtf8().data();

    if(!download_and_store(image_url, tmpname)) {
        return DEFAULT_ALBUM_ART;
    }
    fix_format(tmpname.c_str());
    QFile f(fname);
    if(!f.open(QIODevice::ReadWrite)) {
        return DEFAULT_ALBUM_ART;
    }
    QByteArray arr = f.readAll();
    f.close();

    cache.add_art(info.artist, info.album, arr.data(), arr.size());
    try {
        std::string res = cache.get_art_file(info.artist, info.album);
        if(res.empty())
            return DEFAULT_ALBUM_ART;
        return res;
    } catch(...) {
    }
    return DEFAULT_ALBUM_ART;
}

QImage AlbumArtProvider::requestImage(const QString &id, QSize *realSize, const QSize &requestedSize) {
    Q_UNUSED(requestedSize)

    QUrlQuery query(id);
    if (!query.hasQueryItem(QStringLiteral("artist")) || !query.hasQueryItem(QStringLiteral("album"))) {
        qWarning() << "Invalid albumart uri:" << id;
        return QImage(QString::fromStdString(DEFAULT_ALBUM_ART));
    }
    const QString artist = query.queryItemValue(QStringLiteral("artist"), QUrl::FullyEncoded);
    const QString album = query.queryItemValue(QStringLiteral("album"), QUrl::FullyEncoded);

    std::string tgt_path;
    try {
        tgt_path = get_image(artist.toStdString(), album.toStdString());
        if(!tgt_path.empty()) {
            QImage image;
            image.load(QString::fromStdString(tgt_path));
            // FIXME: Rescale to requested size preserving aspect.
            *realSize = image.size();
            return image;
        }
    } catch(std::exception &e) {
        qDebug() << "Album art loader failed: " << e.what();
    } catch(...) {
        qDebug() << "Unknown error when generating image.";
    }

    QImage fallback(QString::fromStdString(DEFAULT_ALBUM_ART));
    *realSize = fallback.size();
    return fallback;
}
