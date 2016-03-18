#! /bin/bash
#script to id filesystem type for raw disk images using disktype, mount accordingly (currently only hfs and vfat) and then run md5deep to create dfxml and .csv reports
#make cwd a variable
CWD=$(pwd)
echo $CWD
#iterate for every .img file
for FILE in *.img
do
#make variable SYSTEM based on a grep of disktype's output
	SYSTEM=$(disktype "$FILE" | grep "file system")
#if SYSTEM contains FAT
	if [[ $SYSTEM == "FAT"* ]]
	then
#uses fiwalk to create DFXML of image
		fiwalk "$FILE" > "$CWD"/$FILE"-FAT-dfxml.xml"
#mounts the image in order to run md5deep 
		sudo mount -t vfat -o loop,ro,noexec $FILE /mnt/diskid/
#just verify it mounted
		echo $?
#cd to mount directory
		cd /mnt/diskid
#use md5deep to create .csv for use by archivists and appraisers
		md5deep -r -l -t ./* > "$CWD"/$FILE"-FAT-manifest.csv"
#cd back to cwd and unmount
		cd "$CWD"
		sudo umount /mnt/diskid		
#if SYSTEM contains HFS
	elif [[ $SYSTEM == "HFS"* ]]
	then 
#mount the image according to forensicwiki mounting suggestions
		sudo mount -t hfs -o loop,ro,noexec $FILE /mnt/diskid/
#just verify it mounted
		echo $?
#cd to mount directory
		cd /mnt/diskid
#use md5deep to create DFXML and .csv files
		md5deep -r -l -d ./* > "$CWD"/$FILE"-HFS-dfxml.xml"
		md5deep -r -l -t ./* > "$CWD"/$FILE"-HFS-manifest.csv"
#cd back to cwd and unmount
		cd "$CWD"
		sudo umount /mnt/diskid
	fi
done

