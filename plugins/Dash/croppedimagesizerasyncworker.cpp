/*
 * Copyright (C) 2014 Canonical, Ltd.
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

#include "croppedimagesizerasyncworker.h"

#include "croppedimagesizer.h"

#include <QNetworkReply>
#include <QtConcurrentRun>

CroppedImageSizerAsyncWorker::CroppedImageSizerAsyncWorker(CroppedImageSizer *sizer, QNetworkReply *reply)
 : m_sizer(sizer),
   m_reply(reply),
   m_ignoreAbort(false)
{
    connect(m_reply, &QNetworkReply::finished, this, &CroppedImageSizerAsyncWorker::requestFinished);
}

void CroppedImageSizerAsyncWorker::abort()
{
    // This runs on main thread
    QMutexLocker locker(&m_mutex);
    m_sizer = nullptr;
    // If we already started the future run we can't abort the reply
    // since we don't know at which stage the future is, just let it finish
    if (!m_ignoreAbort) {
        QMetaObject::invokeMethod(m_reply, "abort", Qt::QueuedConnection);
    }
}

void CroppedImageSizerAsyncWorker::requestFinished()
{
    // This runs on main thread
    QMutexLocker locker(&m_mutex);
    if (m_sizer) {
        m_ignoreAbort = true;
        QtConcurrent::run(processRequestFinished, m_sizer->width(), m_sizer->height(), m_sizer->source(), this);
    } else {
        // We were aborted delete ourselves
        m_reply->deleteLater();
        deleteLater();
    }
}

void CroppedImageSizerAsyncWorker::processRequestFinished(qreal width, qreal height, QUrl source, CroppedImageSizerAsyncWorker *worker)
{
    // This runs on non main thread
    QImageReader reader(worker->m_reply);
    const QSize imageSize = reader.size();
    QSize sourceSize = QSize(0, 0);
    if (imageSize.isValid()) {
        if (height > 0 && imageSize.height() > 0) {
            const qreal ar = width / height;
            const qreal ssar = imageSize.width() / (qreal)imageSize.height();
            if (ar > ssar) {
                sourceSize = QSize(width, 0);
            } else {
                sourceSize = QSize(0, height);
            }
        }
    } else {
        qWarning() << "Could not find size of" << source << worker;
    }

    worker->m_mutex.lock();
    if (worker->m_sizer) {
        worker->m_sizer->setSourceSize(sourceSize);
    }
    worker->m_mutex.unlock();

    // All work is done, delete ourselves
    worker->m_reply->deleteLater();
    worker->deleteLater();
}
