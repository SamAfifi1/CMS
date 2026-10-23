# Creates cms_master + one empty database per tenant and applies the schema.
# Usage (PowerShell):
#   $env:PGPASSWORD = "password"
#   .\scripts\create-databases.ps1                  # local Postgres 18, port 5432
#   .\scripts\create-databases.ps1 -Port 5433       # Docker Postgres
 
param(
    [string]$PgBin  = "C:\Program Files\PostgreSQL\18\bin",
    [string]$DbHost = "localhost",
    [int]   $Port   = 5432,
    [string]$User   = "postgres"
)
 
$ErrorActionPreference = "Stop"
 
$psql = Join-Path $PgBin "psql.exe"
$conn = @("-h", $DbHost, "-p", $Port, "-U", $User, "-v", "ON_ERROR_STOP=1")
 
# Resolve paths relative to the repository root (the folder above /scripts).
$repoRoot     = Split-Path -Parent $PSScriptRoot
$masterSchema = Join-Path $repoRoot "db\migrations\master\V001__create_tenants.sql"
$tenantSchema = Join-Path $repoRoot "db\migrations\tenant\V001__create_tenant_schema.sql"
$seedFile     = Join-Path $repoRoot "db\seed-tenants.sql"
 
function New-Db($name, $schemaFile) {
    $exists = & $psql @conn -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$name'"
    if ($LASTEXITCODE -ne 0) { throw "Failed to check whether database '$name' exists." }
 
    if ("$exists".Trim() -eq "1") {
        Write-Host "Skipping $name (already exists)"
        return
    }
 
    & $psql @conn -d postgres -c "CREATE DATABASE $name"
    if ($LASTEXITCODE -ne 0) { throw "Failed to create database '$name'." }
 
    & $psql @conn -d $name -f $schemaFile
    if ($LASTEXITCODE -ne 0) { throw "Failed to apply schema to database '$name'." }
 
    Write-Host "Created $name"
}
 
# Master database: schema, then seed tenants.
New-Db "cms_master" $masterSchema
 
& $psql @conn -d cms_master -f $seedFile
if ($LASTEXITCODE -ne 0) { throw "Failed to seed cms_master." }
 
# Read tenant connection strings back from cms_master.
$connectionStrings = & $psql @conn -d cms_master -t -A -c "SELECT connection_string FROM tenants ORDER BY id;"
if ($LASTEXITCODE -ne 0) { throw "Failed to retrieve tenants from cms_master." }
 
foreach ($connectionString in $connectionStrings) {
    $connectionString = "$connectionString".Trim()
    if ([string]::IsNullOrWhiteSpace($connectionString)) { continue }
 
    if ($connectionString -match '(?:^|;)Database=([^;]+)') {
        $databaseName = $Matches[1].Trim()
    }
    else {
        throw "Could not extract Database from connection string: $connectionString"
    }
 
    # Validate the name before using it in SQL.
    if ($databaseName -notmatch '^cms_tenant_[a-zA-Z0-9_]+$') {
        throw "Unexpected tenant database name: $databaseName"
    }
 
    New-Db $databaseName $tenantSchema
}
 
Write-Host "Done."