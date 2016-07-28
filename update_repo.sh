#!/bin/sh -eux

repo_dir=$HOME/$S3_BUCKET
s3_url=s3://$S3_BUCKET

# create repo directory if it doesn't exist
if [ ! -d "$repo_dir" ]; then
  mkdir -pv $repo_dir
fi

# pull down repo, run createrepo, push it back up
aws s3 sync $s3_url $repo_dir
echo `find $repo_dir -mindepth 2 -maxdepth 2 -type d` | xargs -n 1 -P 8 createrepo --update --deltas
aws s3 sync $repo_dir $s3_url --delete --exclude "*.rpm"

# clean up after ourselves
rm -rf $repo_dir
