# Script is used to convert level1 echo images into camera projected images
# This script searches through each images file and checks whether there is a corresponding level1 echo image and if it's 
# converts the images into Camera projected image




for f in *.IMG
do
	echo $f

	filename=$(echo "$f" | cut -f 1 -d '.')
        lev0="_lev0.cub"
        lev1="_lev1.cub"
        lev1echo="_lev1echo.cub"
        cam="_cam.cub"
    fileecho=$filename$lev1echo	
    filecam=$filename$cam
    if [ -f "$fileecho" ]; then
    
        if [ -f "$filecam" ]; then
            echo "CAM already present"
        else
            echo "CAM Processing"
            ##Camprocessing
            mapmap=polarstereographic.map
            ##cam2map from=$fileecho map=$mapmap to=$filecam trim=yes defaultrange=camera minlat=-78.35 maxlat=-78.15 minlon=257 maxlon=258
            #This map can be changed based on the locations and there are different kind f maps
            cam2map from=$fileecho map="/mnt/e/Space/Moon/maps/sinusoidal.map" to=$filecam trim=yes defaultrange=camera minlat=0.4725 maxlat=0.4890 minlon=358.569 maxlon=358.584
        fi
    else
        echo "Something"
    fi
    echo "CAM Project Done for $fileecho" 
done
