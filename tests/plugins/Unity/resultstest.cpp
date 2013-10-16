/*
 * Copyright (C) 2013 Canonical, Ltd.
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
 *
 * Authors:
 *  Michal Hruby <michal.hruby@canonical.com>
 */

#include <QTest>
#include <dee.h>
#include <glib.h>

#include "resultstest.h"
#include "categoryresults.h"
#include "variantutils.h"

static DeeModel* createBackendModel()
{
    auto model = dee_sequence_model_new();
    dee_model_set_schema(model, "s", "s", "u", "u", "s", "s", "s", "s", "a{sv}", NULL);

    return model;
}

void ResultsTest::testAllColumns()
{
    auto deeModel = createBackendModel();
    GVariantBuilder builder;
    g_variant_builder_init(&builder, G_VARIANT_TYPE_VARDICT);
    g_variant_builder_add(&builder, "{sv}", "metadata-field", g_variant_new_string("foo"));
    dee_model_append (deeModel,
                      "test:uri",
                      "themed-icon",
                      4,
                      0,
                      "application/octet-stream",
                      "Test",
                      "Comment",
                      "test:dnd-uri",
                      g_variant_builder_end(&builder));

    CategoryResults* results = new CategoryResults(this);
    results->setModel(deeModel);

    auto index = results->index(0, 0); // there's just one result
    QCOMPARE(index.data(CategoryResults::Roles::RoleUri).toString(), QString("test:uri"));
    QCOMPARE(index.data(CategoryResults::Roles::RoleIconHint).toString(), QString("image://theme/themed-icon"));
    QCOMPARE(index.data(CategoryResults::Roles::RoleCategory).toInt(), 4);
    QCOMPARE(index.data(CategoryResults::Roles::RoleMimetype).toString(), QString("application/octet-stream"));
    QCOMPARE(index.data(CategoryResults::Roles::RoleTitle).toString(), QString("Test"));
    QCOMPARE(index.data(CategoryResults::Roles::RoleComment).toString(), QString("Comment"));
    QCOMPARE(index.data(CategoryResults::Roles::RoleDndUri).toString(), QString("test:dnd-uri"));
    auto metadata = index.data(CategoryResults::Roles::RoleMetadata).toHash();
    QCOMPARE(metadata["metadata-field"].toString(), QString("foo"));
}

void ResultsTest::testIconColumn_data()
{
    QTest::addColumn<QString>("uri");
    QTest::addColumn<QString>("giconString");
    QTest::addColumn<QString>("result");

    QTest::newRow("unspecified") << "test:uri" << "" << "";
    QTest::newRow("absolute path") << "test:uri" << "/usr/share/icons/example.png" << "/usr/share/icons/example.png";
    QTest::newRow("file uri") << "test:uri" << "file:///usr/share/icons/example.png" << "file:///usr/share/icons/example.png";
    QTest::newRow("http uri") << "test:uri" << "http://images.ubuntu.com/example.jpg" << "http://images.ubuntu.com/example.jpg";
    QTest::newRow("image uri") << "test:uri" << "image://thumbnail/with/arguments?passed_to=ImageProvider" << "image://thumbnail/with/arguments?passed_to=ImageProvider";
    QTest::newRow("themed icon") << "test:uri" << "accessories-other" << "image://theme/accessories-other";
    QTest::newRow("fileicon") << "test:uri" << ". GFileIcon http://example.org/resource.gif" << "http://example.org/resource.gif";
    QTest::newRow("themedicon") << "test:uri" << ". GThemedIcon accessories-other accessories generic" << "image://theme/accessories-other,accessories,generic";
    QTest::newRow("annotatedicon") << "test:uri" << ". UnityProtocolAnnotatedIcon %7B'base-icon':%20%3C'.%20GThemedIcon%20accessories-other%20accessories%20generic'%3E%7D" << "image://theme/accessories-other,accessories,generic";
    QTest::newRow("thumbnailer icon") << "file:///usr/share/samples/video/foo.avi" << "" << "image://thumbnailer//usr/share/samples/video/foo.avi";
}

void ResultsTest::testIconColumn()
{
    QFETCH(QString, uri);
    QFETCH(QString, giconString);
    QFETCH(QString, result);
    auto deeModel = createBackendModel();
    dee_model_append (deeModel,
                      uri.toLocal8Bit().constData(),
                      giconString.toLocal8Bit().constData(),
                      0,
                      0,
                      "application/octet-stream",
                      "Test",
                      "",
                      "test:dnd-uri",
                      g_variant_new_array(g_variant_type_element(G_VARIANT_TYPE_VARDICT), NULL, 0));

    CategoryResults* results = new CategoryResults(this);
    results->setModel(deeModel);

    auto index = results->index(0, 0); // there's just one result
    auto transformedIcon = index.data(CategoryResults::Roles::RoleIconHint).toString();
    QCOMPARE(transformedIcon, result);
}

class GVariantWrapper
{
public:
  GVariantWrapper() : variant(NULL) {}
  GVariantWrapper(GVariant* v) {
    variant = v ? g_variant_ref_sink(v) : NULL;
  }
  GVariantWrapper(const GVariantWrapper& other) {
    variant = other.variant ? g_variant_ref(other.variant) : NULL;
  }
  ~GVariantWrapper() {
    if (variant) g_variant_unref(variant);
  }

  GVariant* variant;
};

Q_DECLARE_METATYPE(GVariantWrapper)

void ResultsTest::testSpecialIcons_data()
{
    QTest::addColumn<QString>("uri");
    QTest::addColumn<GVariantWrapper>("metadata");
    QTest::addColumn<QString>("result");

    GVariant *inner;
    GVariantBuilder builder, inner_builder;

    g_variant_builder_init(&inner_builder, G_VARIANT_TYPE_VARDICT);
    g_variant_builder_add(&inner_builder, "{sv}", "artist", g_variant_new_string("U2"));
    g_variant_builder_add(&inner_builder, "{sv}", "album", g_variant_new_string("War"));

    g_variant_builder_init(&builder, G_VARIANT_TYPE_VARDICT);
    g_variant_builder_add(&builder, "{sv}", "content", g_variant_builder_end(&inner_builder));

    QTest::newRow("simple") << "file:///foo.mp3" << GVariantWrapper(g_variant_builder_end(&builder)) << "image://albumart/U2/War";

    g_variant_builder_init(&inner_builder, G_VARIANT_TYPE_VARDICT);
    g_variant_builder_add(&inner_builder, "{sv}", "artist", g_variant_new_string("U2"));
    g_variant_builder_add(&inner_builder, "{sv}", "album", g_variant_new_string("War/Joshua tree"));
    inner = g_variant_builder_end(&inner_builder);

    g_variant_builder_init(&builder, G_VARIANT_TYPE_VARDICT);
    g_variant_builder_add(&builder, "{sv}", "content", inner);

    QTest::newRow("with-slash") << "file:///foo.mp3" << GVariantWrapper(g_variant_builder_end(&builder)) << "image://albumart/U2/War%2FJoshua%20tree";

    g_variant_builder_init(&inner_builder, G_VARIANT_TYPE_VARDICT);
    g_variant_builder_add(&inner_builder, "{sv}", "artist", g_variant_new_string("U2"));
    g_variant_builder_add(&inner_builder, "{sv}", "album", g_variant_new_string("War"));
    inner = g_variant_builder_end(&inner_builder);

    g_variant_builder_init(&inner_builder, G_VARIANT_TYPE_VARDICT);
    g_variant_builder_add(&inner_builder, "{sv}", "content", inner);

    g_variant_builder_init(&builder, G_VARIANT_TYPE_VARDICT);
    g_variant_builder_add(&builder, "{sv}", "content", g_variant_builder_end(&inner_builder));

    QTest::newRow("nested") << "file:///foo.mp3" << GVariantWrapper(g_variant_builder_end(&builder)) << "image://albumart/U2/War";
}

void ResultsTest::testSpecialIcons()
{
    QFETCH(QString, uri);
    QFETCH(GVariantWrapper, metadata);
    QFETCH(QString, result);
    auto deeModel = createBackendModel();
    dee_model_append (deeModel,
                      uri.toLocal8Bit().constData(),
                      "",
                      0,
                      0,
                      "audio/mp3",
                      "Test",
                      "",
                      uri.toLocal8Bit().constData(),
                      metadata.variant);

    CategoryResults* results = new CategoryResults(this);
    results->setModel(deeModel);

    auto index = results->index(0, 0); // there's just one result
    auto transformedIcon = index.data(CategoryResults::Roles::RoleIconHint).toString();
    QCOMPARE(transformedIcon, result);
}

void ResultsTest::testMetadataOverride_data()
{
    QTest::addColumn<QString>("uri");
    QTest::addColumn<QVariantHash>("result");

    QVariantHash expected_result;
    QVariantHash inner_hash;

    expected_result = QVariantHash();
    expected_result["scope-id"] = QVariant::fromValue(QString("applications.scope"));
    expected_result["content"] = QVariant::fromValue(QVariantHash());

    QTest::newRow("single scope") << "subscope:applications.scope" << expected_result;

    expected_result = QVariantHash();
    expected_result["scope-id"] = QVariant::fromValue(QString("applications.scope"));
    inner_hash = QVariantHash();
    inner_hash["foo"] = QVariant::fromValue(QString("bar"));
    inner_hash["qoo"] = QVariant::fromValue(QString("baz"));
    expected_result["content"] = QVariant::fromValue(inner_hash);

    QTest::newRow("single scope with data") << "subscope:applications.scope?foo=bar&qoo=baz" << expected_result;

    expected_result = QVariantHash();
    inner_hash = QVariantHash();
    inner_hash["scope-id"] = QVariant::fromValue(QString("applications-local.scope"));
    inner_hash["content"] = QVariant::fromValue(QVariantHash());
    expected_result["scope-id"] = QVariant::fromValue(QString("applications.scope"));
    expected_result["content"] = QVariant::fromValue(inner_hash);
    QTest::newRow("master scope") << "subscope:applications.scope/applications-local.scope" << expected_result;

    expected_result = QVariantHash();
    expected_result["foo"] = QVariant::fromValue(QString("baz"));
    expected_result["qoo"] = QVariant::fromValue(QString("baz"));
    inner_hash = QVariantHash();
    inner_hash["scope-id"] = QVariant::fromValue(QString("applications-local.scope"));
    inner_hash["content"] = QVariant::fromValue(expected_result);
    expected_result = QVariantHash();
    expected_result["scope-id"] = QVariant::fromValue(QString("applications.scope"));
    expected_result["content"] = QVariant::fromValue(inner_hash);
    QTest::newRow("nested with data") << "subscope:applications.scope/applications-local.scope?foo=baz&qoo=baz" << expected_result;
}

void ResultsTest::testMetadataOverride()
{
    QFETCH(QString, uri);
    QFETCH(QVariantHash, result);

    QCOMPARE(subscopeUriToMetadataHash(uri), result);
}

QTEST_MAIN(ResultsTest)
