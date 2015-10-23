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

#include "globalshortcut.h"

#include <QtTest>
#include <QtQuick/QQuickView>
#include <QtQuick/QQuickItem>
#include <QQmlEngine>

class GlobalShortcutTest: public QObject
{
    Q_OBJECT

private Q_SLOTS:

    void initTestCase()
    {
        m_view = new QQuickView();
        m_view->engine()->addImportPath(BUILT_PLUGINS_DIR);
        m_view->setSource(QUrl::fromLocalFile(CURRENT_SOURCE_DIR "/shortcut.qml"));
        m_shortcut = dynamic_cast<GlobalShortcut*>(m_view->rootObject()->property("shortcut").value<QObject*>());
        QVERIFY(m_shortcut);
        m_inactiveShortcut = dynamic_cast<GlobalShortcut*>(m_view->rootObject()->property("inactiveShortcut").value<QObject*>());
        QVERIFY(m_inactiveShortcut);
        m_view->show();
        QTest::qWaitForWindowExposed(m_view);
    }

    void cleanupTestCase()
    {
        m_view.clear();
    }

    void testGlobalShortcut()
    {
        QSignalSpy shortcutSpy(m_shortcut, &GlobalShortcut::triggered);
        // test pressing "Mute Volume"
        QTest::keyClick(m_view, Qt::Key_VolumeMute);
        QTRY_COMPARE(shortcutSpy.count(), 1);
        const QVariantList args = shortcutSpy.takeFirst();
        // verify we got the signal back and a non-empty shortcut
        QCOMPARE(args.count(), 1);
        QVERIFY(!args.first().toString().isEmpty());
    }

    void testInactiveGlobalShortcut()
    {
        QSignalSpy shortcutSpy(m_inactiveShortcut, &GlobalShortcut::triggered);
        // test pressing Ctrl+Alt+L
        QTest::keyClick(m_view, Qt::Key_L, Qt::ControlModifier|Qt::AltModifier);
        // verify we didn't get any signal back, shortcut is not active
        QTRY_COMPARE(shortcutSpy.count(), 0);
    }

private:
    QPointer<QQuickView> m_view;
    GlobalShortcut *m_shortcut = nullptr;
    GlobalShortcut *m_inactiveShortcut = nullptr;
};

QTEST_MAIN(GlobalShortcutTest)

#include "GlobalShortcutTest.moc"
