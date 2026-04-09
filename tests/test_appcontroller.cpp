// SPDX-License-Identifier: MIT
/*
 * EverFree — Testes para AppController (fluxos principais)
 */

#include <QtTest/QtTest>
#include <QDir>
#include <QTemporaryDir>
#include "AppController.hpp"

class TestAppController : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void testInitialState();
    void testModeChange();
    void testAddFolder();
    void testAddFolder_validation();
    void testRemoveFolder();
    void testClearFolders();
    void testDefaultMode_persistence();
    void testAdvancedSettings();
    void testCancelSafety();
    void testErrorHandling();
    void cleanupTestCase();

private:
    AppController* m_controller = nullptr;
};

void TestAppController::initTestCase()
{
    m_controller = new AppController(this);
    QVERIFY(m_controller != nullptr);
}

void TestAppController::testInitialState()
{
    QCOMPARE(m_controller->state(), AppController::AppState::Idle);
    QCOMPARE(m_controller->mode(), AppController::AppMode::None);
    QVERIFY(m_controller->fileModel() != nullptr);
    QVERIFY(m_controller->reportModel() != nullptr);
    QVERIFY(m_controller->progressModel() != nullptr);
    QVERIFY(m_controller->simpleStatus().length() > 0);
}

void TestAppController::testModeChange()
{
    QSignalSpy spy(m_controller, &AppController::modeChanged);
    
    m_controller->setMode(AppController::AppMode::Simple);
    QCOMPARE(m_controller->mode(), AppController::AppMode::Simple);
    QCOMPARE(spy.count(), 1);
    
    m_controller->setMode(AppController::AppMode::Advanced);
    QCOMPARE(m_controller->mode(), AppController::AppMode::Advanced);
    QCOMPARE(spy.count(), 2);
}

void TestAppController::testAddFolder()
{
    QSignalSpy spy(m_controller, &AppController::folderPathsChanged);
    QString testPath = QDir::homePath();
    
    m_controller->addFolder(testPath);
    QCOMPARE(m_controller->folderPaths().contains(testPath), true);
    QCOMPARE(spy.count(), 1);
    
    // Adding same folder should not trigger signal
    m_controller->addFolder(testPath);
    QCOMPARE(spy.count(), 1); // No change
}

void TestAppController::testAddFolder_validation()
{
    int initialCount = m_controller->folderPaths().size();
    
    // FIX validation: empty strings should be rejected
    m_controller->addFolder("");
    QCOMPARE(m_controller->folderPaths().size(), initialCount);
    
    m_controller->addFolder("   ");
    QCOMPARE(m_controller->folderPaths().size(), initialCount);
    
    m_controller->addFolder("\t\n");
    QCOMPARE(m_controller->folderPaths().size(), initialCount);
}

void TestAppController::testRemoveFolder()
{
    QSignalSpy spy(m_controller, &AppController::folderPathsChanged);
    QString testPath = QDir::homePath();
    
    // Ensure we have at least one folder
    m_controller->addFolder(testPath);
    int countBefore = m_controller->folderPaths().size();
    
    // Remove valid index
    m_controller->removeFolder(0);
    QCOMPARE(m_controller->folderPaths().size(), countBefore - 1);
    QVERIFY(spy.count() > 0);
    
    // Remove invalid index should not crash
    m_controller->removeFolder(-1);
    m_controller->removeFolder(999);
}

void TestAppController::testClearFolders()
{
    m_controller->addFolder("/tmp/test1");
    m_controller->addFolder("/tmp/test2");
    QVERIFY(m_controller->folderPaths().size() >= 2);
    
    QSignalSpy spy(m_controller, &AppController::folderPathsChanged);
    m_controller->clearFolders();
    QCOMPARE(m_controller->folderPaths().size(), 0);
    QCOMPARE(spy.count(), 1);
}

void TestAppController::testDefaultMode_persistence()
{
    QSignalSpy spy(m_controller, &AppController::defaultModeChanged);
    
    m_controller->setDefaultMode(1); // Simple
    QCOMPARE(m_controller->defaultMode(), 1);
    QCOMPARE(spy.count(), 1);
    
    m_controller->setDefaultMode(2); // Advanced
    QCOMPARE(m_controller->defaultMode(), 2);
    QCOMPARE(spy.count(), 2);
}

void TestAppController::testAdvancedSettings()
{
    // Test all advanced settings with signal tracking
    {
        QSignalSpy spy(m_controller, &AppController::vcodecChanged);
        m_controller->setVcodec("h265");
        QCOMPARE(m_controller->vcodec(), QString("h265"));
        QCOMPARE(spy.count(), 1);
    }
    
    {
        QSignalSpy spy(m_controller, &AppController::crfChanged);
        m_controller->setCrf(23);
        QCOMPARE(m_controller->crf(), 23);
        QCOMPARE(spy.count(), 1);
    }
    
    {
        QSignalSpy spy(m_controller, &AppController::maxResChanged);
        m_controller->setMaxRes("720p");
        QCOMPARE(m_controller->maxRes(), QString("720p"));
        QCOMPARE(spy.count(), 1);
    }
    
    {
        QSignalSpy spy(m_controller, &AppController::threadsChanged);
        m_controller->setThreads(4);
        QCOMPARE(m_controller->threads(), 4);
        QCOMPARE(spy.count(), 1);
    }
    
    {
        QSignalSpy spy(m_controller, &AppController::recursiveChanged);
        m_controller->setRecursive(false);
        QCOMPARE(m_controller->recursive(), false);
        QCOMPARE(spy.count(), 1);
    }
}

void TestAppController::testCancelSafety()
{
    // Cancel should be safe to call even when nothing is running
    QSignalSpy spy(m_controller, &AppController::stateChanged);
    
    m_controller->cancel();
    
    // Should return to idle
    QCOMPARE(m_controller->state(), AppController::AppState::Idle);
    
    // Multiple cancels should be safe
    m_controller->cancel();
    m_controller->cancel();
}

void TestAppController::testErrorHandling()
{
    // Test error tracking
    m_controller->clearErrors();
    QCOMPARE(m_controller->errorCount(), 0);
    QCOMPARE(m_controller->errorPaths().size(), 0);
    
    // Clear when empty should be safe
    m_controller->clearErrors();
}

void TestAppController::cleanupTestCase()
{
    // Clean reset
    m_controller->cancel();
    m_controller->clearFolders();
    m_controller->clearErrors();
}

QTEST_MAIN(TestAppController)
#include "test_appcontroller.moc"
