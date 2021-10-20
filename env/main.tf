terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "resource_group_name" {}

variable "resources_location" {
  default = "westus2"
}

variable "storage_account_name" {
  default = "dbstorage"
}

variable "database_server_name" {
  default = "dbserver"
}

variable "database_name" {
  default = "db"
}

variable "database_user_name" {
  default = "4dm1n157r470r"
}

variable "database_user_password" {
  default = "4-v3ry-53cr37-p455w0rd"
}

variable "automation_account_name" {
  default = "autoacc"
}

variable "automation_runbook_name" {
  default = "autorunbook"
}

variable "runbook_script_file_name" {
  default = "run-job"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resources_location
}

resource "azurerm_storage_account" "sa" {
  name                     = format("%s%s", azurerm_resource_group.rg.name, var.storage_account_name)
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_mssql_server" "dbserver" {
  name                         = format("%s%s", azurerm_resource_group.rg.name, var.database_server_name)
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.database_user_name
  administrator_login_password = var.database_user_password
}

resource "azurerm_mssql_firewall_rule" "dbserverfwrule" {
  name             = format("firewallrule")
  server_id        = azurerm_mssql_server.dbserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

resource "azurerm_mssql_database" "database" {
  name         = format("%s%s", azurerm_resource_group.rg.name, var.database_name)
  server_id    = azurerm_mssql_server.dbserver.id
  license_type = "LicenseIncluded"
}

resource "null_resource" "database_create_table" {
  depends_on = [
    azurerm_mssql_database.database
  ]
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "sqlcmd -S ${azurerm_mssql_server.dbserver.name}.database.windows.net -d ${azurerm_mssql_database.database.name} -U ${var.database_user_name} -P ${var.database_user_password} -i ../scripts/create-table.sql"
  }
}

resource "null_resource" "database_create_procedure" {
  depends_on = [
    azurerm_mssql_database.database
  ]
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "sqlcmd -S ${azurerm_mssql_server.dbserver.name}.database.windows.net -d ${azurerm_mssql_database.database.name} -U ${var.database_user_name} -P ${var.database_user_password} -i ../scripts/create-procedure.sql"
  }
}

resource "azurerm_automation_account" "acc" {
  name                = format("%s%s", azurerm_resource_group.rg.name, var.automation_account_name)
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "Basic"
}

data "local_file" "runbook_script" {
  filename = "../scripts/run-job.ps1"
}

resource "azurerm_automation_runbook" "runbook" {
  name                    = var.runbook_script_file_name # MUST MATCH THE SCRIPT`s
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  automation_account_name = azurerm_automation_account.acc.name
  log_verbose             = "true"
  log_progress            = "true"
  runbook_type            = "PowerShellWorkflow"
  content                 = data.local_file.runbook_script.content
}

resource "azurerm_automation_schedule" "runbook_schedule" {
  name                    = "Automation-Schedule"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.acc.name
  frequency               = "Hour"
}

resource "azurerm_automation_job_schedule" "runbook_job_schedule" {
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.acc.name
  runbook_name            = azurerm_automation_runbook.runbook.name
  schedule_name           = azurerm_automation_schedule.runbook_schedule.name
}
