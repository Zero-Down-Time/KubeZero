### v1.33

# All things BEFORE the first controller / control plane upgrade
pre_control_plane_upgrade_cluster() {
  echo
}


# All things after the first controller / control plane upgrade
post_control_plane_upgrade_cluster() {
  echo
}


# All things AFTER all contollers are on the new version
pre_cluster_upgrade_final() {
  set +e

  echo

  set -e
}


# Last call
post_cluster_upgrade_final() {
  echo
}
