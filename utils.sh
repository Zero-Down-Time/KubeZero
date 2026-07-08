# bumps git tag using semVer
bumpVersion() {
  V=$1
  type=${2:-patch}

  if [ "$type" == 'patch' ]; then
    awkV='{OFS="."; $NF+=1; print $0}'
  elif [ "$type" == 'minor' ]; then
    awkV='{OFS="."; $2+=1; $3=0; print $0}'
  elif [ "$type" == 'major' ]; then
    awkV='{OFS="."; $1+=1; $2=0; $3=0; print "v"$0}'
  else
    echo 'No version type specified.  Specify one of patch, minor, or major.'
    exit 1
  fi

  echo $V | awk -F. "$awkV"
}


# add resources, commits and tags them, before pushing
addCommitTagPush() {
  OBS="$1"
  V="$2"

  if [ -n "$OBS" ]; then
    git add "$OBS"
    git commit -m "ci: bump, tag and push version $V" || true
  fi

  if [ -n "$V" ]; then
    git tag -a "$V" -m "Release: $V"
    git push && git push --tags
  fi
}
