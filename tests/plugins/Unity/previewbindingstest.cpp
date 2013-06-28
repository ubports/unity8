/*
 * Copyright (C) 2011, 2013 Canonical, Ltd.
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

#include "previewbindingstest.h"
#include <QTest>

#include <UnityCore/Preview.h>
#include <UnityCore/GLibWrapper.h>
#include <unity-protocol.h>

#include "genericpreview.h"
#include "applicationpreview.h"
#include "moviepreview.h"
#include "musicpreview.h"

void PreviewBindingsTest::initTestCase()
{
}

void PreviewBindingsTest::testGenericPreview()
{
    auto raw_preview = (GObject *)unity_protocol_generic_preview_new();
    unity_protocol_preview_set_title(UNITY_PROTOCOL_PREVIEW(raw_preview), "Metallica");
    unity_protocol_preview_set_subtitle(UNITY_PROTOCOL_PREVIEW(raw_preview), "Ride The Lightning");
    unity_protocol_preview_set_description(UNITY_PROTOCOL_PREVIEW(raw_preview), "Lorem ipsum dolor sit amet");
    unity::glib::Object<GObject> gen_prv(raw_preview);

    auto core_prv = unity::dash::Preview::PreviewForProtocolObject(gen_prv);
    auto prv = Preview::newFromUnityPreview(core_prv);

    QCOMPARE(prv != nullptr, true);
    QCOMPARE(prv->title(), QString("Metallica"));
    QCOMPARE(prv->subtitle(), QString("Ride The Lightning"));
    QCOMPARE(prv->description(), QString("Lorem ipsum dolor sit amet"));
}

void PreviewBindingsTest::testApplicationPreview()
{
    auto raw_preview = (GObject *)unity_protocol_application_preview_new();
    unity_protocol_preview_set_title(UNITY_PROTOCOL_PREVIEW(raw_preview), "Firefox");
    unity_protocol_preview_set_subtitle(UNITY_PROTOCOL_PREVIEW(raw_preview), "Web Browser");
    unity_protocol_preview_set_description(UNITY_PROTOCOL_PREVIEW(raw_preview), "Lorem ipsum dolor sit amet");
    unity_protocol_application_preview_set_license(UNITY_PROTOCOL_APPLICATION_PREVIEW(raw_preview), "GPL");
    unity::glib::Object<GObject> gen_prv(raw_preview);

    auto core_prv = unity::dash::Preview::PreviewForProtocolObject(gen_prv);
    auto prv = Preview::newFromUnityPreview(core_prv);
    auto app_prv = dynamic_cast<ApplicationPreview*>(prv);

    QCOMPARE(app_prv != nullptr, true);
    QCOMPARE(app_prv->title(), QString("Firefox"));
    QCOMPARE(app_prv->subtitle(), QString("Web Browser"));
    QCOMPARE(app_prv->description(), QString("Lorem ipsum dolor sit amet"));
    QCOMPARE(app_prv->license(), QString("GPL"));
}

void PreviewBindingsTest::testMoviePreview()
{
    auto raw_preview = (GObject *)unity_protocol_movie_preview_new();
    unity_protocol_preview_set_title(UNITY_PROTOCOL_PREVIEW(raw_preview), "Blade Runner");
    unity_protocol_preview_set_subtitle(UNITY_PROTOCOL_PREVIEW(raw_preview), "Ridley Scott");
    unity_protocol_preview_set_description(UNITY_PROTOCOL_PREVIEW(raw_preview), "Lorem ipsum dolor sit amet");
    unity_protocol_movie_preview_set_year(UNITY_PROTOCOL_MOVIE_PREVIEW(raw_preview), "1982");
    unity::glib::Object<GObject> gen_prv(raw_preview);

    auto core_prv = unity::dash::Preview::PreviewForProtocolObject(gen_prv);
    auto prv = Preview::newFromUnityPreview(core_prv);
    auto movie_prv = dynamic_cast<MoviePreview*>(prv);

    QCOMPARE(movie_prv != nullptr, true);
    QCOMPARE(movie_prv->title(), QString("Blade Runner"));
    QCOMPARE(movie_prv->subtitle(), QString("Ridley Scott"));
    QCOMPARE(movie_prv->description(), QString("Lorem ipsum dolor sit amet"));
    QCOMPARE(movie_prv->year(), QString("1982"));
}

void PreviewBindingsTest::testMusicPreview()
{
    auto raw_preview = (GObject *)unity_protocol_music_preview_new();
    unity_protocol_preview_set_title(UNITY_PROTOCOL_PREVIEW(raw_preview), "Metallica");
    unity_protocol_preview_set_subtitle(UNITY_PROTOCOL_PREVIEW(raw_preview), "Death Magnetic");
    unity_protocol_preview_set_description(UNITY_PROTOCOL_PREVIEW(raw_preview), "Lorem ipsum dolor sit amet");
    unity::glib::Object<GObject> gen_prv(raw_preview);

    auto core_prv = unity::dash::Preview::PreviewForProtocolObject(gen_prv);
    auto prv = Preview::newFromUnityPreview(core_prv);
    auto music_prv = dynamic_cast<MusicPreview*>(prv);

    QCOMPARE(music_prv != nullptr, true);
    QCOMPARE(music_prv->title(), QString("Metallica"));
    QCOMPARE(music_prv->subtitle(), QString("Death Magnetic"));
    QCOMPARE(music_prv->description(), QString("Lorem ipsum dolor sit amet"));
}

QTEST_MAIN(PreviewBindingsTest)

#include "previewbindingstest.moc"
