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

#include <QQuickView>
#include <QQmlContext>
#include <QQmlEngine>
#include <QDebug>

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

    m_view->setSource(QUrl("qrc:qml/indicatorsclient.qml"));
    m_view->setResizeMode(QQuickView::SizeRootObjectToView);

    //Usable size on desktop
    m_view->setMinimumSize(QSize(480, 720));
}

int IndicatorsClient::run()
{
    setupUI();
    m_view->showMaximized();
    return m_application->exec();
}
