# shellcheck disable=2034
pkg_name=hab-studio
pkg_origin=core
pkg_version=$(cat "$SRC_PATH/../../VERSION")
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_deps=(
  core/busybox-static 
  core/hab/$pkg_version
  core/hab-backline/$pkg_version
  core/hab-plan-build/$pkg_version
)
pkg_build_deps=(core/coreutils
                core/tar
                core/xz
                core/wget
                core/busybox-static
                core/hab)
pkg_bin_dirs=(bin)

do_prepare() {
  set_runtime_env "HAB_STUDIO_BACKLINE_PKG" "$(pkg_path_for core/hab-backline | cut -d/ -f 4,5,6,7)"
  set_runtime_env "HAB_STUDIO_HAB_PKG" "$(pkg_path_for core/hab | cut -d/ -f 4,5,6,7)"
  set_runtime_env "HAB_STUDIO_PLAN_BUILD_PKG" "$(pkg_path_for core/hab-plan-build | cut -d/ -f 4,5,6,7)"
  set_runtime_env "HAB_STUDIO_BUSYBOX_PKG" "$(pkg_path_for core/busybox-static | cut -d/ -f 4,5,6,7)"
  set_runtime_env "bb" "$(pkg_path_for core/busybox-static)/bin/busybox"
  set_runtime_env "hab" "$(pkg_path_for core/hab)/bin/hab"
  set_runtime_env "libexec_path" "$pkg_prefix/libexec"
}

do_build() {
  cp -v "$SRC_PATH"/bin/hab-studio.sh hab-studio
  cp -v "$SRC_PATH"/libexec/hab-studio-profile.sh .
  cp -v "$SRC_PATH"/libexec/hab-studio-type-*.sh .

  # Embed the release version and author information of the program.
  # shellcheck disable=2154
  sed \
    -e "s,@author@,$pkg_maintainer,g" \
    -e "s,@version@,$pkg_version/$pkg_release,g" \
    -i hab-studio
}

do_install() {
  # shellcheck disable=2154
  install -v -D hab-studio "$pkg_prefix"/bin/hab-studio
  install -v -D hab-studio-profile.sh "$pkg_prefix"/libexec/hab-studio-profile.sh
  for f in hab-studio-type-*.sh; do
    [[ -e $f ]] || break # see http://mywiki.wooledge.org/BashPitfalls#pf1
    install -v -D "$f" "$pkg_prefix"/libexec/"$f"
  done

  cp -rv "${SRC_PATH}/defaults" "${pkg_prefix}"
}
