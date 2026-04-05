// SPDX-License-Identifier: MIT
/*
 * Copyright (C) 2018 Marco Antônio Bueno da Silva <bueno.marco@gmail.com>
 *
 * This file is part of batchpress — Qt6 Desktop GUI scan report model implementation.
 */

#include "ScanReportModel.hpp"

ScanReportModel::ScanReportModel(QObject* parent)
    : QObject(parent)
{}

void ScanReportModel::loadReport(const batchpress::FileScanReport& report)
{
    m_report = report;
    m_valid = true;
    emit reportChanged();
}

void ScanReportModel::clear()
{
    m_report = batchpress::FileScanReport{};
    m_valid = false;
    emit reportChanged();
}
