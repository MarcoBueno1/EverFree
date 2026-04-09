// SPDX-License-Identifier: MIT
/*
 * EverFree — Testes para FileUtils
 */

#include <QtTest/QtTest>
#include "FileUtils.hpp"

class TestFileUtils : public QObject
{
    Q_OBJECT

private slots:
    void testFormatBytes();
    void testFormatBytes_edge_cases();
    void testFormatDuration();
};

void TestFileUtils::testFormatBytes()
{
    QCOMPARE(batchpress::gui::formatBytes(0), QString("0 B"));
    QCOMPARE(batchpress::gui::formatBytes(100), QString("100 B"));
    // Locale-aware: can be "1,0 KB" or "1.0 KB" depending on system locale
    QString kb_result = batchpress::gui::formatBytes(1024);
    QVERIFY(kb_result.contains("1") && kb_result.contains("KB"));
    
    QString result_1536 = batchpress::gui::formatBytes(1536);
    QVERIFY(result_1536.contains("1") && result_1536.contains("KB"));
    
    QString mb_result = batchpress::gui::formatBytes(1048576);
    QVERIFY(mb_result.contains("1") && mb_result.contains("MB"));
}

void TestFileUtils::testFormatBytes_edge_cases()
{
    // Very large numbers
    QString result = batchpress::gui::formatBytes(5368709120ULL); // 5 GB
    QVERIFY(result.contains("5") && result.contains("GB"));
}

void TestFileUtils::testFormatDuration()
{
    QCOMPARE(batchpress::gui::formatDuration(0), QString("0s"));
    QCOMPARE(batchpress::gui::formatDuration(30), QString("30s"));
    QCOMPARE(batchpress::gui::formatDuration(60), QString("1m 0s"));
    QCOMPARE(batchpress::gui::formatDuration(3661), QString("1h 1m"));
}

QTEST_MAIN(TestFileUtils)
#include "test_fileutils.moc"
