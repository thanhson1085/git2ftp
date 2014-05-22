#!bin/bash

echo 'WIP Starting...'
expected_args=0
e_badargs=65
home_dir=$PWD/../
current_time=$(date "+%Y.%m.%d-%H.%M.%S")

if [ $# -ne $expected_args ]
then
    echo "Error: you should use command $0 version dbuser dbpass"
    exit $e_badargs
fi

cd $home_dir
echo "Running update source code from MASTER branch..."
git pull origin master

cd $home_dir/app/config/
for config_file in *.wip
do
    echo "Genarating ${config_file%.*}..."
    cp $config_file ${config_file%.*}
done

echo "DONE!!!"
