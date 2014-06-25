#!bin/bash

REMOTE_DIR="/public_html/staging/"

echo 'STAGING Starting...'
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
old_tag="$1"
if [ $old_tag = "" ]
then
	echo "Error no tag"
	exit
fi

new_tag="$2"
if [ $new_tag = "" ]
then
	echo "Error no tag"
	exit
fi

# get lastest commit by tag name
old_commit=`git rev-list $old_tag|head -n 1`

count_file=0

# get list file changed and push to FTP server
for file_change in `git diff --name-only $old_commit HEAD@{0}`
do
	echo "Put $file_change ..."
	count_file=$((count_file+1))
    # call FTP script to push file via curl
	bash $home_dir/deploy/ftp.sh $file_change $REMOTE_DIR$file_change
done


# Mark repository a new tag
if [ $count_file -gt 0 ]
then

	git tag -a $new_tag -m "Version $new_tag"
	git push origin $new_tag
fi

echo "DONE!!!"
