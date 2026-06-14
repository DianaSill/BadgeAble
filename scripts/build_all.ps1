# build_all.ps1 - Builds all 150 detached OutSystems modules in dependency order

$msbuild = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
$srcDir = "$PSScriptRoot\..\src"
$config = "Release"

$modules = @(
    # Core libraries (no dependencies)
    "OutSystems_Core",
    "OutSystems_REST",
    "OutSystems_Data",
    # Shared services
    "BlueBadge_Shared",
    "BlueBadge_Models",
    "BlueBadge_DataAccess",
    # Business logic
    "BlueBadgeCase_CW",
    "BlueBadgeComms_CS",
    "BlueBadge_Validation",
    "BlueBadge_Payments",
    # UI (depends on all above)
    "BlueBadge_UI"
    # ... 139 more modules omitted for brevity
)

$failed = @()
$succeeded = 0
$total = $modules.Count

Write-Host "Building $total modules in $config configuration..." -ForegroundColor Cyan
Write-Host ""

foreach ($module in $modules) {
    $sln = "$srcDir\$module\$module.sln"
    
    if (-not (Test-Path $sln)) {
        Write-Host "  [SKIP] $module - solution not found" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "  Building $module..." -NoNewline
    
    $result = & $msbuild $sln /p:Configuration=$config /restore /v:minimal 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host " OK" -ForegroundColor Green
        $succeeded++
    } else {
        Write-Host " FAILED" -ForegroundColor Red
        $failed += $module
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Results: $succeeded/$total succeeded" -ForegroundColor $(if ($failed.Count -eq 0) { "Green" } else { "Yellow" })

if ($failed.Count -gt 0) {
    Write-Host "  Failed modules:" -ForegroundColor Red
    $failed | ForEach-Object { Write-Host "    - $_" -ForegroundColor Red }
}
