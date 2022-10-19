#! /bin/bash
#script to id filesystem type for raw disk images using disktype, mount accordingly (currently only hfs and vfat),
#run sf to create .csv reports, 
#use rsync to extract files to /Extracted folder
#assumes /mnt/diskid exists
#assumes disktype, hashdeep are installed


#make cwd a variable
CWD=$(pwd)
echo $CWD


echo "You need to have sudo permission to run this script, requires disk mounting"

#iterate for every .img file (warning: recursive search for .img files based on extension, limit depth on this with find with -maxdepth)
##for FILE in *.img
for FILE in $(find . -name '*.img');
do
#make variable SYSTEM based on a grep of disktype's output
	SYSTEM=$(disktype "$FILE" | grep "file system")
	printf "File: %s , System: %s\n" "$FILE" "$SYSTEM" 
#make variable DIR based on directory containing $FILE
	DIR=$(dirname $(realpath $FILE))

#if SYSTEM contains FAT
	if [[ $SYSTEM == "FAT"* ]]
	then
#mounts the image in order to run md5deep, note the mount command 
		sudo mount -t vfat -o loop,ro,noexec $FILE /mnt/diskid/
#just verify it mounted
		echo $?
#cd to mount directory,
#IMPORTANT NOTE:::: assumes /mnt/diskid exists
		cd /mnt/diskid
#use hashdeep to create .csv for use by archivists OR dfxmls (comment out the one you don't want)
		sf -csv -hash md5 . > $DIR"/"$(basename ${FILE%".img"})"-manifest.csv" 
		#hashdeep -r -l -d -c md5 ./* > $DIR"/"$(basename ${FILE%".img"})"-dfxml.xml"
#rsync -a all files to $/DIR/Extracted/
		mkdir -m 777 $DIR/Extracted
		rsync -rltv . $DIR/Extracted/
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
#use hashdeep to create DFXML and .csv files OR dfxmls (comment out the one you don't want)
		sf -csv -hash md5 . > $DIR"/"$(basename ${FILE%".img"})"-manifest.csv"
		#hashdeep -r -l -d -c md5 ./* > $DIR"/"$(basename ${FILE%".img"})"-dfxml.xml"
#rsync -a all files to $DIR/Extracted/
#add -n flag to test dry run
		rsync -rltv ./ $DIR/Extracted/ 
#cd back to cwd and unmount
		cd "$CWD"
		sudo umount /mnt/diskid	
	fi
done
		
for FILE in $(find ./ -name '*.iso')
do
	SYSTEM=$(disktype "$FILE" | grep "file system")	
	printf "File: %s , System: %s\n\n" "$FILE" "$SYSTEM"

	DIR=$(dirname $(realpath $FILE))
	mkdir -m 777 $DIR/Extracted	
	
#uses fiwalk to create DFXML of image
	#fiwalk -f -X $DIR"/"$(basename ${FILE%".iso"})"-ISO-dfxml.xml" "$FILE"
	
	sudo mount -o loop,ro,noexec $FILE /mnt/diskid/
	echo $?
	cd /mnt/diskid
	echo "changed to /mnt/diskid/ about to LS..."
	ls
	#use siegfried to create .csv files 
	sf -csv -hash md5 . > $DIR"/"$(basename ${FILE%".iso"})"-manifest.csv"

#add -n flag to test dry run
	rsync -rltv . $DIR/Extracted/ 
#cd back to cwd and unmount
	cd "$CWD"
	sudo umount /mnt/diskid	

done

