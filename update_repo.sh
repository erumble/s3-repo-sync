#!/bin/sh -eu

repo_dir=`mktemp -d -t`
s3_url=s3://$S3_BUCKET
retry_count=0

function cleanup {
  # clean up after ourselves
  rm -rf $repo_dir
}
trap cleanup EXIT

function gen_metadata {
  # make sure our tmp directory is clean
  rm -rf $repo_dir/*

  # pull down repo and generate metadata, run create repo in parallel
  aws s3 sync $s3_url $repo_dir --delete
  echo `find $repo_dir -mindepth 2 -maxdepth 2 -type d` | xargs -n 1 -P 8 createrepo --update --deltas

  # Do the uploady stuff
  validate_and_sync
}

function validate_and_sync {
  # compare the local copy of version with the remote, so we know if the repo has been updated since we started
  local version=`curl --retry 3 --silent http://$S3_BUCKET.s3-website-$REGION.amazonaws.com/version`

  if [ "$version" == `cat $repo_dir/version` ]; then
    # generate new version number and sync the repo
    echo `uuidgen` > $repo_dir/version
    aws s3 sync $repo_dir $s3_url --delete --exclude "*.rpm"
  elif (( $retry_count < 3 )); then
    # start over
    let retry_count+=1
    gen_metadata
  else
    # give up
    echo "could not validate and sync"
    exit 1
  fi
}

# ENTRY POINT!!!
gen_metadata

