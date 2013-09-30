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
#include <UnityCore/Variant.h>
#include <unity-protocol.h>

#include "genericpreview.h"
#include "applicationpreview.h"
#include "moviepreview.h"
#include "musicpreview.h"
#include "socialpreview.h"
#include "socialpreviewcomment.h"
#include "previewaction.h"

#include <glib.h>
#include <glib-object.h>

void PreviewBindingsTest::initTestCase()
{
}

void PreviewBindingsTest::testGenericPreview()
{
    auto rawPreview = (GObject *)unity_protocol_generic_preview_new();
    unity_protocol_preview_set_title(UNITY_PROTOCOL_PREVIEW(rawPreview), "Metallica");
    unity_protocol_preview_set_subtitle(UNITY_PROTOCOL_PREVIEW(rawPreview), "Ride The Lightning");
    unity_protocol_preview_set_description(UNITY_PROTOCOL_PREVIEW(rawPreview), "Lorem ipsum dolor sit amet");
    GFile *iconFile = g_file_new_for_path("/foo.png");
    GIcon *icon =  g_file_icon_new(iconFile);
    unity_protocol_preview_add_action(UNITY_PROTOCOL_PREVIEW(rawPreview), "1", "Action1", icon,
                                      UNITY_PROTOCOL_LAYOUT_HINT_LEFT);
    unity::glib::Object<GObject> genPrv(rawPreview);

    // create local result
    unity::glib::HintsMap hints;
    hints["a"] = unity::glib::Variant(g_variant_new_string("b"));
    unity::dash::LocalResult localResult;
    localResult.uri = "http://foo";
    localResult.icon_hint = "xyz";
    localResult.category_index = 1;
    localResult.result_type = 2;
    localResult.mimetype = "abc";
    localResult.name = "baz";
    localResult.comment = "qwerty";
    localResult.dnd_uri = "zzz";
    localResult.hints = hints;

    auto corePrv = unity::dash::Preview::PreviewForProtocolObject(genPrv);
    corePrv->preview_result = localResult;

    auto prv = Preview::newFromUnityPreview(corePrv);

    QCOMPARE(prv != nullptr, true);
    QCOMPARE(prv->title(), QString("Metallica"));
    QCOMPARE(prv->subtitle(), QString("Ride The Lightning"));
    QCOMPARE(prv->description(), QString("Lorem ipsum dolor sit amet"));

    auto actions = prv->actions().value<QList<QObject *>>();
    QCOMPARE(actions.size(), 1);
    auto act = dynamic_cast<PreviewAction *>(actions[0]);
    QVERIFY(act != nullptr);
    QCOMPARE(act->id(), QString("1"));
    QCOMPARE(act->displayName(), QString("Action1"));
    QCOMPARE(act->iconHint(), QString("/foo.png"));

    Result* res = prv->result().value<Result*>();
    QCOMPARE(res->uri(), QString("http://foo"));
    QCOMPARE(res->iconHint(), QString("xyz"));
    QCOMPARE(res->categoryIndex(), 1u);
    QCOMPARE(res->resultType(), 2u);
    QCOMPARE(res->mimeType(), QString("abc"));
    QCOMPARE(res->title(), QString("baz"));
    QCOMPARE(res->dndUri(), QString("zzz"));
    QCOMPARE(res->metadata().toHash()["a"].toString(), QString("b"));

    g_object_unref(icon);
    g_object_unref(iconFile);
}

void PreviewBindingsTest::testApplicationPreview()
{
    auto rawPreview = (GObject *)unity_protocol_application_preview_new();
    unity_protocol_preview_set_title(UNITY_PROTOCOL_PREVIEW(rawPreview), "Firefox");
    unity_protocol_preview_set_subtitle(UNITY_PROTOCOL_PREVIEW(rawPreview), "Web Browser");
    unity_protocol_preview_set_description(UNITY_PROTOCOL_PREVIEW(rawPreview), "Lorem ipsum dolor sit amet");
    unity_protocol_application_preview_set_license(UNITY_PROTOCOL_APPLICATION_PREVIEW(rawPreview), "GPL");
    unity_protocol_application_preview_set_rating(UNITY_PROTOCOL_APPLICATION_PREVIEW(rawPreview), 0.5f);
    unity_protocol_application_preview_set_num_ratings(UNITY_PROTOCOL_APPLICATION_PREVIEW(rawPreview), 4);
    unity::glib::Object<GObject> genPrv(rawPreview);

    auto corePrv = unity::dash::Preview::PreviewForProtocolObject(genPrv);
    auto prv = Preview::newFromUnityPreview(corePrv);
    auto appPrv = dynamic_cast<ApplicationPreview*>(prv);

    QCOMPARE(appPrv != nullptr, true);
    QCOMPARE(appPrv->title(), QString("Firefox"));
    QCOMPARE(appPrv->subtitle(), QString("Web Browser"));
    QCOMPARE(appPrv->description(), QString("Lorem ipsum dolor sit amet"));
    QCOMPARE(appPrv->license(), QString("GPL"));
    QCOMPARE(appPrv->rating(), 0.5f);
    QCOMPARE(appPrv->numRatings(), unsigned (4));
}

void PreviewBindingsTest::testMoviePreview()
{
    auto rawPreview = (GObject *)unity_protocol_movie_preview_new();
    unity_protocol_preview_set_title(UNITY_PROTOCOL_PREVIEW(rawPreview), "Blade Runner");
    unity_protocol_preview_set_subtitle(UNITY_PROTOCOL_PREVIEW(rawPreview), "Ridley Scott");
    unity_protocol_preview_set_description(UNITY_PROTOCOL_PREVIEW(rawPreview), "Lorem ipsum dolor sit amet");
    unity_protocol_movie_preview_set_year(UNITY_PROTOCOL_MOVIE_PREVIEW(rawPreview), "1982");
    unity::glib::Object<GObject> genPrv(rawPreview);

    auto corePrv = unity::dash::Preview::PreviewForProtocolObject(genPrv);
    auto prv = Preview::newFromUnityPreview(corePrv);
    auto moviePrv = dynamic_cast<MoviePreview*>(prv);

    QCOMPARE(moviePrv != nullptr, true);
    QCOMPARE(moviePrv->title(), QString("Blade Runner"));
    QCOMPARE(moviePrv->subtitle(), QString("Ridley Scott"));
    QCOMPARE(moviePrv->description(), QString("Lorem ipsum dolor sit amet"));
    QCOMPARE(moviePrv->year(), QString("1982"));
}

void PreviewBindingsTest::testMusicPreview()
{
    auto rawPreview = (GObject *)unity_protocol_music_preview_new();
    unity_protocol_preview_set_title(UNITY_PROTOCOL_PREVIEW(rawPreview), "Metallica");
    unity_protocol_preview_set_subtitle(UNITY_PROTOCOL_PREVIEW(rawPreview), "Death Magnetic");
    unity_protocol_preview_set_description(UNITY_PROTOCOL_PREVIEW(rawPreview), "Lorem ipsum dolor sit amet");
    unity::glib::Object<GObject> genPrv(rawPreview);

    auto corePrv = unity::dash::Preview::PreviewForProtocolObject(genPrv);
    auto prv = Preview::newFromUnityPreview(corePrv);
    auto musicPrv = dynamic_cast<MusicPreview*>(prv);

    QCOMPARE(musicPrv != nullptr, true);
    QCOMPARE(musicPrv->title(), QString("Metallica"));
    QCOMPARE(musicPrv->subtitle(), QString("Death Magnetic"));
    QCOMPARE(musicPrv->description(), QString("Lorem ipsum dolor sit amet"));
}

void PreviewBindingsTest::testSocialPreview()
{
    GFile *iconFile = g_file_new_for_path("/foo.png");
    GIcon *icon =  g_file_icon_new(iconFile);

    auto rawPreview = (GObject *)unity_protocol_social_preview_new();
    unity_protocol_social_preview_set_sender(UNITY_PROTOCOL_SOCIAL_PREVIEW(rawPreview), "John");
    unity_protocol_social_preview_set_avatar(UNITY_PROTOCOL_SOCIAL_PREVIEW(rawPreview), icon);
    unity_protocol_social_preview_set_content(UNITY_PROTOCOL_SOCIAL_PREVIEW(rawPreview), "Lorem ipsum dolor sit amet");
    unity_protocol_social_preview_add_comment(UNITY_PROTOCOL_SOCIAL_PREVIEW(rawPreview), "1", "comment1", "Ubuntu", "2013-07-04 14:10");
    unity::glib::Object<GObject> genPrv(rawPreview);

    auto corePrv = unity::dash::Preview::PreviewForProtocolObject(genPrv);
    auto prv = Preview::newFromUnityPreview(corePrv);
    auto socialPrv = dynamic_cast<SocialPreview*>(prv);

    QCOMPARE(socialPrv != nullptr, true);
    QCOMPARE(socialPrv->sender(), QString("John"));
    QCOMPARE(socialPrv->content(), QString("Lorem ipsum dolor sit amet"));
    QCOMPARE(socialPrv->avatar(), QString("/foo.png"));

    auto comments = socialPrv->comments().value<QList<QObject *>>();
    QCOMPARE(comments.size(), 1);
    auto cmt = dynamic_cast<SocialPreviewComment *>(comments[0]);
    QVERIFY(cmt != nullptr);
    QCOMPARE(cmt->id(), QString("1"));
    QCOMPARE(cmt->displayName(), QString("comment1"));
    QCOMPARE(cmt->content(), QString("Ubuntu"));
    QCOMPARE(cmt->time(), QString("2013-07-04 14:10"));

    g_object_unref(icon);
    g_object_unref(iconFile);
}

QTEST_MAIN(PreviewBindingsTest)
