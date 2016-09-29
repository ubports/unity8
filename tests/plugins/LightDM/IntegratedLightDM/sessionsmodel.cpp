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

    static QModelIndex findByKey(QAbstractItemModel *model, const QString& key)
    {
        for (int i = 0; i < model->rowCount(QModelIndex()); i++) {
            if (model->data(model->index(i, 0), QLightDM::SessionsModel::KeyRole).toString() == key)
                return model->index(i, 0);
        }

        return QModelIndex();
    }

    void testIconDirectoriesAreValid()
    {
        Q_FOREACH(const QUrl& searchDirectory, model->iconSearchDirectories())
        {
            QVERIFY(searchDirectory.isValid());
        }
    }

    void testIconLookupLogic()
    {
        const QString data[][2] = {
                                    //{SESSION KEY, ICON NAME}
                                    {"gnome-classic", "gnome_badge.png"},
                                    {"gnome-flashback-compiz", "gnome_badge.png"},
                                    {"gnome-flashback-metacity", "gnome_badge.png"},
                                    {"gnome-shell", "gnome_badge.png"},
                                    {"gnome-wayland", "gnome_badge.png"},
                                    {"gnome", "gnome_badge.png"},
                                    {"kde", "kde_badge.png"},
                                    {"plasma", "kde_badge.png"},
                                    {"recovery_console", "recovery_console_badge.png"},
                                    {"ubuntu","ubuntu_badge.png"},
                                    {"ubuntu-2d", "ubuntu_badge.png"},
                                    {"xterm", "recovery_console_badge.png"},
                                    {"made up session", "unknown_badge.png"},
                                    {"", "unknown_badge.png"}
                                  };

        const short length = sizeof(data) / sizeof(data[0]);
        for (int i = 0; i < length; i++) {
            std::string key = data[i][0].toStdString();
            std::string icon = data[i][1].toStdString();
            std::string url = model->iconUrl(data[i][0]).toString().toStdString();
            std::string errorMessage = "Session icon url for " + key +
                " should contain " + icon + " but " + url + " was returned";
            QVERIFY2(model->iconUrl(data[i][0]).toString().contains(data[i][1]),
                    errorMessage.c_str());
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

    void testSessionNameIsCorrect()
    {
        // This is testing the lookup, not the correctness of the strings,
        // so one test should be sufficient
        sourceModel->setTestScenario("multipleSessions");
        QVERIFY(model->data(findByKey(sourceModel, "ubuntu"),
                Qt::DisplayRole).toString() == "Ubuntu");
    }

private:
    SessionsModel *model;
    QLightDM::SessionsModel *sourceModel;
};

QTEST_MAIN(GreeterSessionsModelTest)

#include "sessionsmodel.moc"
