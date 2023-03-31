cp $1  $2/$1 | pv -lep -s $(du -sb $1 | awk '{print $1}')
