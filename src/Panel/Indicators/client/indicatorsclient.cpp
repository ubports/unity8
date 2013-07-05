/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

#include "indicatorsclient.h"
#include "paths.h"

#include <QQuickView>
#include <QQmlContext>
#include <QQmlEngine>
#include <QDebug>

void prependImportPaths(QQmlEngine *engine, const QStringList &paths)
{
    QStringList importPathList = engine->importPathList();
    for (int i = paths.count()-1; i >= 0; i--) {
        importPathList.prepend(paths[i]);
    }
    engine->setImportPathList(importPathList);
}

/* When you append and import path to the list of import paths it will be the *last*
   place where Qt will search for QML modules.
   The usual QQmlEngine::addImportPath() actually prepends the given path.*/
void appendImportPaths(QQmlEngine *engine, const QStringList &paths)
{
    QStringList importPathList = engine->importPathList();
    Q_FOREACH(const QString& path, paths) {
        // don't duplicate
        QStringList::iterator iter = qFind(importPathList.begin(), importPathList.end(), path);
        if (iter == importPathList.end()) {
            importPathList.append(path);
        }
    }
    engine->setImportPathList(importPathList);
}

IndicatorsClient::IndicatorsClient(int &argc, char **argv)
    : QObject(0),
      m_view(0)
{
    m_application = new QApplication(argc, argv);
}

IndicatorsClient::~IndicatorsClient()
{
    if (m_view != 0) {
        delete m_view;
    }

    delete m_application;
}

void IndicatorsClient::setupUI()
{
    m_view = new QQuickView;
    m_view->engine()->setBaseUrl(QUrl::fromLocalFile(::shellAppDirectory()+"Panel/Indicators/client/"));
    prependImportPaths(m_view->engine(), ::overrideImportPaths());
    appendImportPaths(m_view->engine(), ::fallbackImportPaths());

    m_view->setSource(QUrl("IndicatorsClient.qml"));
    m_view->setResizeMode(QQuickView::SizeRootObjectToView);

    //Usable size on desktop
    m_view->setMinimumSize(QSize(480, 720));
}

int IndicatorsClient::run()
{
    setupUI();
    m_view->show();
    return m_application->exec();
}
