pkg_name=spring-petclinic
pkg_origin=jtimberman
pkg_version=4.2.6
pkg_maintainer='The Habitat Maintainers <humans@habitat.sh>'
pkg_license=('Apache-2.0')
pkg_source=${pkg_name}-${pkg_version}.tar.bz2
pkg_shasum="calculated"
pkg_upstream_url=https://github.com/habitat-sh/spring-petclinic
pkg_description="A sample Spring-based application, customized by the Habitat maintainers for example purposes"

pkg_expose=(8080)

pkg_deps=(
  core/glibc
  core/tomcat8
  core/jre8
  core/mysql
)

pkg_build_deps=(
  core/maven
  core/jdk8
  core/which
  core/coreutils
  core/diffutils
  core/patch
  core/make
  core/gcc
)

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

pkg_svc_user="root"
pkg_svc_group="root"

do_begin() {
  return 0
}

do_build() {
  export JAVA_HOME=$(hab pkg path core/jdk8)
  mvn package
}

do_install() {
  cp $HAB_CACHE_SRC_PATH/${pkg_dirname}/target/petclinic.war $pkg_prefix
}

do_download() {
  pushd ../
  build_line "Creating ${pkg_name}-${pkg_version}.tar.bz2 from application source"
  tar -cjf $HAB_CACHE_SRC_PATH/${pkg_name}-${pkg_version}.tar.bz2 \
		  --transform "s,^\.,spring-petclinic-${pkg_version}," \
      --exclude .git --exclude habitat .
  popd
  pkg_shasum=$(trim $(sha256sum /hab/cache/src/${pkg_name}-${pkg_version}.tar.bz2 | cut -d " " -f 1))
}
