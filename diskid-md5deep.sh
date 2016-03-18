#! /bin/bash
#script to id filesystem type for raw disk images using disktype, mount accordingly and then run md5deep to create dfxml and .csv reports
#make cwd a variable
CWD=$(pwd)
echo $CWD
#iterate for every .img file
for FILE in *.img
do
#make variable SYSTEM based on a grep of disktype's output
	SYSTEM=$(disktype "$FILE" | grep "file system")
#if SYSTEM contains FAT bla
	if [[ $SYSTEM == "FAT"* ]]
	then
#mount command based on forensicswiki instructions mount to /mnt/diskid
		sudo mount -t vfat -o loop,ro,noexec $FILE /mnt/diskid/
#just verifies if the mount was successfull
		echo $?
#change directory to mount location in order to run mdeep
		cd /mnt/diskid
#uses md5deep to create DFXML of image
		md5deep -r -l -d ./* > "$CWD"/$FILE"-dfxml.xml"
#uses md5deep to create .csv for use by archivists and appraisers
		md5deep -r -l -t ./* > "$CWD"/$FILE"-manifest.csv"
#return to cwd
		cd "$CWD"
#unmount image
		sudo umount /mnt/diskid
#repeat above if SYSTEM contains HFS
	elif [[ $SYSTEM == "HFS"* ]]
	then 
		sudo mount -t hfs -o loop,ro,noexec $FILE /mnt/diskid/
		echo $?
		cd /mnt/diskid
		md5deep -r -l -d ./* > "$CWD"/$FILE"-dfxml.xml"
		md5deep -r -l -t ./* > "$CWD"/$FILE"-manifest.csv"
		cd "$CWD"
		sudo umount /mnt/diskid
	fi
done

