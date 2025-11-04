#!/bin/sh

CONF=$(find . -name peer[1-9].conf | sort )
#configという名のディレクトリ内の*.confファイルを順に取得して色々する
for file_path in $CONF; do 

    echo "#### Config file: $file_path ####"
    echo '```'
    cat $file_path
    echo '```'

    echo ' '
done