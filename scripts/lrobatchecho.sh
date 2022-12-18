for f in *.IMG
do
	echo $f

	filename=$(echo "$f" | cut -f 1 -d '.')
        lev0="_lev0.cub"
        lev1="_lev1.cub"
        lev1echo="_lev1echo.cub"
    filecho=$filename$lev1echo	
    if [ -f "$filecho" ]; then
        echo "fileprocessed"
    else
        lronac2isis from=$filename.IMG to=$filename$lev0
        spiceinit from=$filename$lev0 web=yes
        lronaccal from=$filename$lev0 to=$filename$lev1
        rm -f $filename$lev0
        lronacecho from=$filename$lev1 to=$filename$lev1echo
        rm -f $filename$lev1
    fi

done
