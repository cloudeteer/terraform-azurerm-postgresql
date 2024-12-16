mock_data "azurerm_monitor_diagnostic_categories" {
  defaults = {
    log_category_groups = [
      "allLogs",
      "audit",
    ]
    log_category_types = [
      "PostgreSQLFlexDatabaseXacts",
      "PostgreSQLFlexQueryStoreRuntime",
      "PostgreSQLFlexQueryStoreWaitStats",
      "PostgreSQLFlexSessions",
      "PostgreSQLFlexTableStats",
      "PostgreSQLLogs",
    ]
    metrics = [
      "AllMetrics",
    ]
  }
}
