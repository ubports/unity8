/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#include "SessionsModel.h"

#include <QLightDM/SessionsModel>
#include <QtCore/QModelIndex>
#include <QtTest>
#include <QString>

class GreeterSessionsModelTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:

    void init()
    {
        model = new SessionsModel();
        QVERIFY(model);
        sourceModel = new QLightDM::SessionsModel();
        QVERIFY(sourceModel);
    }

    void cleanup()
    {
        delete model;
        delete sourceModel;
    }

    void testIconDirectoriesAreValid()
    {
        Q_FOREACH(const QUrl& searchDirectory, model->iconSearchDirectories())
        {
            QVERIFY(searchDirectory.isValid());
        }
    }

    void testMultipleSessionsCountIsCorrect()
    {
        sourceModel->setTestScenario("multipleSessions");
        QVERIFY(sourceModel->rowCount(QModelIndex()) > 1);
    }

    void testNoSessionsCountIsCorrect()
    {
        sourceModel->setTestScenario("noSessions");
        QVERIFY(sourceModel->rowCount(QModelIndex()) == 0);
    }

    void testSingleSessionCountIsCorrect()
    {
        sourceModel->setTestScenario("singleSession");
        QVERIFY(sourceModel->rowCount(QModelIndex()) == 1);
    }

private:
    SessionsModel *model;
    QLightDM::SessionsModel *sourceModel;
};

QTEST_MAIN(GreeterSessionsModelTest)

#include "sessionsmodel.moc"
