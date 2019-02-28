#! /bin/bash
#script to id filesystem type for raw disk images using disktype, mount accordingly (currently only hfs and vfat) and then run md5deep to create dfxml and .csv reports
#make cwd a variable
CWD=$(pwd)
echo $CWD
#LOGFILE=script.log
#iterate for every .img file
##for FILE in *.img
for FILE in $(find ./ -name '*.img');
do
#make variable SYSTEM based on a grep of disktype's output
	SYSTEM=$(disktype "$FILE" | grep "file system")
	printf "File: %s , System: %s\n" "$FILE" "$SYSTEM" #>> $LOGFILE
#if SYSTEM contains FAT
	if [[ $SYSTEM == "FAT"* ]]
	then
#uses fiwalk to create DFXML of image
		fiwalk -f -X "$CWD"/$FILE"-FAT-dfxml.xml" "$FILE" 
#mounts the image in order to run md5deep, note the mount command 
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
	elif [[ $SYSTEM == "ISO"* ]]
	then 
		fiwalk -f -X "$CWD"/$FILE"-ISO-dfxml.xml" "$FILE"
		
	fi
done
		
for FILE in $(find ./ -name '*.iso')
do
		SYSTEM=$(disktype "$FILE" | grep "file system")
#uses fiwalk to create DFXML of image
		fiwalk -f -X "$CWD"/$FILE"-ISO-dfxml.xml" "$FILE"
		printf "File: %s , System: %s\n\n" "$FILE" "$SYSTEM" #>> $LOGFILE
done
