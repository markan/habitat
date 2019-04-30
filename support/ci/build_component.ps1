#!/usr/bin/env powershell

#Requires -Version 5

param (
    # The name of the component to be built. Defaults to none
    [string]$Component
)

# Since we are only verifying we don't have build failures, make everything
# temp!
$env:HAB_ORIGIN="throwaway"

Write-Host "--- :key: Generating fake origin key"
hab origin key generate
Write-Host "--- :hab: Running hab pkg build for $Component"

hab studio build components/$Component

exit $LASTEXITCODE
