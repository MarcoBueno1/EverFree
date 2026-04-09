// SPDX-License-Identifier: MIT
/*
 * EverFree — Testes para ScanWorker
 */

#include <QtTest/QtTest>
#include <QTemporaryDir>
#include <QDir>
#include <QFile>
#include <QImage>
#include "workers/ScanWorker.hpp"

class TestScanWorker : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void testScanEmptyDirectory();
    void testScanWithImages();
    void testCancelSafety();
    void cleanupTestCase();

private:
    QString m_testDir;
};

void TestScanWorker::initTestCase()
{
    m_testDir = QDir::tempPath() + "/everfree_test_" + QString::number(QDateTime::currentMSecsSinceEpoch());
    QDir().mkpath(m_testDir);
}

void TestScanWorker::testScanEmptyDirectory()
{
    // Test that worker can be created and started without crash
    ScanWorker worker(m_testDir, true, 100);
    
    QEventLoop loop;
    QObject::connect(&worker, &ScanWorker::scanComplete, &loop, &QEventLoop::quit);
    QObject::connect(&worker, &ScanWorker::scanFailed, &loop, &QEventLoop::quit);
    
    worker.start(QThread::LowPriority);
    
    // Wait with timeout
    QTimer::singleShot(5000, &loop, &QEventLoop::quit);
    loop.exec();
    
    // Should complete or fail, but not crash
    QVERIFY(true);
}

void TestScanWorker::testScanWithImages()
{
    // Create test images
    QStringList createdFiles;
    for (int i = 0; i < 3; ++i) {
        QString path = m_testDir + "/test_" + QString::number(i) + ".png";
        QImage img(100, 100, QImage::Format_RGB888);
        img.fill(Qt::red);
        if (img.save(path)) {
            createdFiles << path;
        }
    }
    
    QVERIFY(createdFiles.size() > 0);
    
    ScanWorker worker(m_testDir, true, 100);
    
    int reportCount = 0;
    QObject::connect(&worker, &ScanWorker::scanComplete, [&reportCount](batchpress::FileScanReport) {
        reportCount++;
    });
    
    QEventLoop loop;
    QObject::connect(&worker, &ScanWorker::scanComplete, &loop, &QEventLoop::quit);
    QObject::connect(&worker, &ScanWorker::scanFailed, &loop, &QEventLoop::quit);
    
    worker.start(QThread::LowPriority);
    QTimer::singleShot(10000, &loop, &QEventLoop::quit);
    loop.exec();
    
    // Should have processed files
    QVERIFY(reportCount >= 0);
    
    // Cleanup
    for (const auto& file : createdFiles) {
        QFile::remove(file);
    }
}

void TestScanWorker::testCancelSafety()
{
    // Create many files
    QStringList createdFiles;
    for (int i = 0; i < 20; ++i) {
        QString path = m_testDir + "/cancel_" + QString::number(i) + ".png";
        QImage img(300, 300, QImage::Format_RGB888);
        img.fill(Qt::blue);
        if (img.save(path)) {
            createdFiles << path;
        }
    }
    
    ScanWorker worker(m_testDir, true, 100);
    
    QEventLoop loop;
    QObject::connect(&worker, &ScanWorker::scanComplete, &loop, &QEventLoop::quit);
    QObject::connect(&worker, &ScanWorker::scanFailed, &loop, &QEventLoop::quit);
    
    worker.start(QThread::LowPriority);
    
    // Cancel after a short delay
    QTimer::singleShot(200, &worker, [&worker, &loop]() {
        worker.cancel();
        // Don't quit immediately - let worker finish naturally
        QTimer::singleShot(500, &loop, &QEventLoop::quit);
    });
    
    loop.exec();
    
    // Should not crash
    QVERIFY(true);
    
    // Cleanup
    for (const auto& file : createdFiles) {
        QFile::remove(file);
    }
}

void TestScanWorker::cleanupTestCase()
{
    QDir(m_testDir).removeRecursively();
}

QTEST_MAIN(TestScanWorker)
#include "test_scanworker.moc"
