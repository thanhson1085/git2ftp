#!bin/bash

REMOTE_DIR="/public_html/"

echo 'LIVE Starting...'
expected_args=2
e_badargs=65
home_dir=$PWD/../
current_time=$(date "+%Y.%m.%d-%H.%M.%S")

if [ $# -ne $expected_args ]
then
    echo "Error: you should use command $0 old_tag new_tag"
    exit $e_badargs
fi

cd $home_dir
lastest_tag="$2"
if [ $lastest_tag = "" ]
then
	echo "Error no tag"
	exit
fi
old_tag="$1"
if [ $old_tag = "" ]
then
	echo "Error no tag"
	exit
fi

# get the lastest commit via tag name
new_commit=`git rev-list $lastest_tag|head -n 1`

# get the lastest commit via tag name
old_commit=`git rev-list $old_tag|head -n 1`

count_file=0
# get list file changed
for file_change in `git diff --name-only $old_commit $new_commit`
do
	echo "Put $file_change ..."
	count_file=$((count_file+1))
    # call ftp script to push file via curl
	bash $home_dir/deploy/ftp.sh $file_change $REMOTE_DIR$file_change
done

echo "DONE!!!"
