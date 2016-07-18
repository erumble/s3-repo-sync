#!/bin/sh -eux

repo_dir=$HOME/$S3_BUCKET
s3_url=s3://$S3_BUCKET

# create repo directory if it doesn't exist
if [ ! -d "$repo_dir" ]; then
  mkdir -pv $repo_dir
fi

# pull down repo, run createrepo, push it back up
aws s3 sync $s3_url $repo_dir
pushd $repo_dir
  createrepo --update --deltas .
  for arch in noarch SRPMS x86_64; do
    if [ ! -d "$arch" ]; then
      mkdir $arch
    fi
    createrepo --update --deltas $arch
  done
popd

aws s3 sync $repo_dir $s3_url --delete

# clean up after ourselves
rm -rf $repo_dir
