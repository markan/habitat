$pkg_name="hab-studio"
$pkg_origin="core"
$pkg_version=Get-Content "$PLAN_CONTEXT/../../../VERSION"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_license=@("Apache-2.0")
$pkg_deps=@("core/powershell", "core/hab", "core/hab-plan-build-ps1", "core/7zip")
$pkg_bin_dirs=@("bin")

function _Get-Ident() {
  param([String]dep)

  $path_to_dep = Get-HabPackagePath $dep.Split("/")[1]

  (Get-Content "$path_to_dep/IDENT").Trim()
}

function Invoke-Prepare {
  Push-RuntimeEnv HAB_STUDIO_HAB_PKG "$(_Get-Ident hab)"
  Push-RuntimeEnv HAB_STUDIO_7ZIP_PKG "$(_Get-Ident 7zip)"
  Push-RuntimeEnv HAB_STUDIO_POWERSHELL_PKG "$(_Get-Ident powershell)"
  Push-RuntimeEnv HAB_STUDIO_PLAN_BUILD_PKG "$(_Get-Ident "hab-plan-build-ps1")"
}

function Invoke-Build {
  Get-Content "$PLAN_CONTEXT/../bin/hab-studio.ps1" | % {
    $_.Replace("@author@", $pkg_maintainer).Replace("@version@", $pkg_version)
  } | Add-Content -Path hab-studio.ps1
}

function Invoke-Install {
  Copy-Item hab-studio.ps1 "$pkg_prefix/bin/hab-studio.ps1"
  Copy-Item $PLAN_CONTEXT/../bin/hab-studio.bat "$pkg_prefix/bin/hab-studio.bat"
  Copy-Item $PLAN_CONTEXT/../bin/SupervisorBootstrapper.cs "$pkg_prefix/bin/SupervisorBootstrapper.cs"
}
