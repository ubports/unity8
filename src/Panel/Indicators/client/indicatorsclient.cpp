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

#include <paths.h>

#include <QQuickView>
#include <QQmlContext>
#include <QQmlEngine>
#include <QDebug>

IndicatorsClient::IndicatorsClient(int &argc, char **argv)
    : QObject(0),
      m_view(0)
{
    m_application = new QApplication(argc, argv);

    QStringList args = m_application->arguments();

    m_view = new QQuickView;
    m_view->engine()->setBaseUrl(QUrl::fromLocalFile(::qmlDirectory()+"Panel/Indicators/client/"));
    prependImportPaths(m_view->engine(), ::overrideImportPaths());
    appendImportPaths(m_view->engine(), ::fallbackImportPaths());

    QString profile = "phone";
    if (args.contains(QLatin1String("-profile")) && args.size() > args.indexOf(QLatin1String("-profile")) + 1) {
        profile = args.at(args.indexOf(QLatin1String("-profile")) + 1);
    }
    m_view->rootContext()->setContextProperty("indicatorProfile", profile);

    m_view->setSource(QUrl("IndicatorsClient.qml"));
    m_view->setResizeMode(QQuickView::SizeRootObjectToView);
    if (args.contains(QLatin1String("-windowgeometry")) && args.size() > args.indexOf(QLatin1String("-windowgeometry")) + 1) {
        QStringList geometryArg = args.at(args.indexOf(QLatin1String("-windowgeometry")) + 1).split('x');
        if (geometryArg.size() == 2) {
            m_view->resize(geometryArg.at(0).toInt(), geometryArg.at(1).toInt());
        }
    }
    else {
        //Usable size on desktop
        m_view->setMinimumSize(QSize(480, 720));
    }
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

}

int IndicatorsClient::run()
{
    m_view->show();
    return m_application->exec();
}
