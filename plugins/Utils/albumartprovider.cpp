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
#include <QBuffer>
#include<cstdio>
#include<QDebug>
#include<QFile>
#include<QByteArray>
#include<gst/gst.h>
#include<unistd.h>
#include<memory>
#include<QImage>

using namespace std;

static void on_new_pad (GstElement * /*dec*/, GstPad * pad, GstElement * fakesink) {
    GstPad *sinkpad;

    sinkpad = gst_element_get_static_pad (fakesink, "sink");
    if (!gst_pad_is_linked (sinkpad)) {
        if (gst_pad_link (pad, sinkpad) != GST_PAD_LINK_OK)
            g_error ("Failed to link pads!");
    }
    gst_object_unref (sinkpad);
}

static void process_one_tag (const GstTagList * list, const gchar * tag, gpointer user_data) {
    struct albuminfo *md = (struct albuminfo*) user_data;
    int i, num;
    string tagname(tag);

    num = gst_tag_list_get_tag_size (list, tag);
    for (i = 0; i < num; ++i) {
        gchar *val;
        if (gst_tag_get_type(tag) == G_TYPE_STRING) {
        if (gst_tag_list_get_string_index (list, tag, i, &val)) {
            if(tagname == "artist")
                md->artist = std::string(val);
            if(tagname == "album")
                md->album = std::string(val);
        }}
    }
}

albuminfo AlbumArtProvider::get_album_info(const std::string &filename) throw (runtime_error) 
{
    albuminfo ai;
    // FIXME: Need to do quoting. Files with %'s in their names seem to confuse gstreamer.

    const string uri = "file://" + filename;

    GstElement *dec = gst_element_factory_make ("uridecodebin", NULL);
    if (dec == nullptr)
        throw runtime_error("Failed to create uridecodebin element");

    GstElement *pipe = gst_pipeline_new ("pipeline");

    g_object_set (dec, "uri", uri.c_str(), NULL);
    gst_bin_add (GST_BIN (pipe), dec);

    GstElement *sink = gst_element_factory_make ("fakesink", NULL);
    gst_bin_add (GST_BIN (pipe), sink);
    g_signal_connect (dec, "pad-added", G_CALLBACK (on_new_pad), sink);

    gst_element_set_state (pipe, GST_STATE_PAUSED);

    GstMessage *msg;
    while (true) {
      GstTagList *tags = NULL;

      msg = gst_bus_timed_pop_filtered(GST_ELEMENT_BUS (pipe),
          GST_CLOCK_TIME_NONE, (GstMessageType) (GST_MESSAGE_ASYNC_DONE | GST_MESSAGE_TAG | GST_MESSAGE_ERROR));

      if (GST_MESSAGE_TYPE (msg) != GST_MESSAGE_TAG) /* error or async_done */
        break;

      gst_message_parse_tag (msg, &tags);
      gst_tag_list_foreach (tags, process_one_tag, &ai);
      gst_tag_list_unref (tags);

      gst_message_unref (msg);
    };

    gst_element_set_state (pipe, GST_STATE_NULL);
    gst_object_unref (pipe);

    if (GST_MESSAGE_TYPE (msg) == GST_MESSAGE_ERROR) {
        GError *err;
        gchar *dbg_info;
        gst_message_parse_error(msg, &err, &dbg_info);
        string errortxt(err->message);
        string dbtxt(dbg_info);
        g_error_free(err);
        g_free(dbg_info);

        gst_message_unref (msg);
        string msg = "Extracting metadata of file ";
        msg += filename;
        msg += " failed: ";
        msg += errortxt;
        msg += " ";
        msg += dbg_info;
        throw runtime_error(msg);
    }

    gst_message_unref (msg);

    return ai;
}

std::string AlbumArtProvider::get_lastfm_url(const albuminfo &ai) {
    QString artist = QString::fromStdString(ai.artist);
    QString album = QString::fromStdString(ai.album);

    /// @todo: this is the old API which will probably get axed at some point in the future
    ///        The new 2.0 API requires an API key, but supports JSON output, etc, so switching
    ///        to it should be done ASAP.
    QString request = QString("http://ws.audioscrobbler.com/1.0/album/%1/%2/info.xml").arg(artist)
                                                                                      .arg(album)
                                                                                      .toHtmlEscaped();
    QScopedPointer<QNetworkAccessManager> am(new QNetworkAccessManager);
    QNetworkReply *reply = am->get(QNetworkRequest(QUrl(request)));
    QEventLoop loop;
    QObject::connect(am.data(), &QNetworkAccessManager::finished, &loop, &QEventLoop::quit);
    loop.exec();

    if (reply->error() != QNetworkReply::NoError) {
        qWarning() << "Error getting the XML:" << reply->errorString();
        return "";
    }

    QXmlQuery query;
    QBuffer tmp;
    tmp.setData(reply->readAll());
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

    QScopedPointer<QNetworkAccessManager> am(new QNetworkAccessManager);
    QNetworkReply *reply = am->get(QNetworkRequest(QUrl(url)));
    QEventLoop loop;
    QObject::connect(am.data(), &QNetworkAccessManager::finished, &loop, &QEventLoop::quit);
    loop.exec();

    if (reply->error() != QNetworkReply::NoError) {
        qWarning() << "Error getting the image:" << reply->errorString();
        return false;
    }

    QFile file(fileName);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        qWarning() << "Could not open file for writing:" << file.errorString();
        return false;
    }
    if (file.write(reply->readAll()) == -1){
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

std::string AlbumArtProvider::get_image(const std::string &filename) {
    albuminfo info;
    try {
        info = get_album_info(filename);
    } catch(std::exception &e) {
        qDebug() << "Could not determine album info: " << e.what();
        return "";
    }
    if(info.album.empty() || info.artist.empty()) {
        return "";
    }
    if(cache.has_art(info.artist, info.album)) {
        // Image may have expired from cache between these two lines.
        // It might expire before we return. C'est la vie.
        return cache.get_art_file(info.artist, info.album);
    }
    std::string image_url = get_lastfm_url(info);
    if(image_url.empty()) {
        return "";
    }
    char tmpname[] = "/tmp/path/to/some/file/somewhere/maybe.jpg";
    tmpnam(tmpname);
    //std::unique_ptr<char, int(*)(const char*)> deleter(tmpname, unlink);
    if(!download_and_store(image_url, tmpname)) {
        return "";
    }
    fix_format(tmpname);
    FILE *f = fopen(tmpname, "r");
    fseek(f, 0, SEEK_END);
    long s = ftell(f);
    fseek(f, 0, SEEK_SET);
    char *buf = new char[s];
    fread(buf, 1, s, f);
    fclose(f);

    // Fixme, leaks buf if throws.
    cache.add_art(info.artist, info.album, buf, s);
    delete []buf;
    return cache.get_art_file(info.artist, info.album);
}

QImage AlbumArtProvider::requestImage(const QString &id, QSize *realSize, const QSize &requestedSize) {
    Q_UNUSED(requestedSize)

    std::string src_path(id.toUtf8().data());
    std::string tgt_path;
    try {
        tgt_path = get_image(src_path);
        if(!tgt_path.empty()) {
            QString tgt(tgt_path.c_str());
            QImage image;
            image.load(tgt);
            // FIXME: Rescale to requested size preserving aspect.
            *realSize = image.size();
            return image;
        }
    } catch(std::exception &e) {
        qDebug() << "Album art loader failed: " << e.what();
    } catch(...) {
        qDebug() << "Unknown error when generating image.";
    }

    *realSize = QSize(0, 0);
    return QImage();
}
