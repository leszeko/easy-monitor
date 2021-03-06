#!/bin/bash
# new_hdt-0.5.2.iso.sh script
# Test Install Hardware Detection Tool iso to Grub boot menu

Begin () {
prepare_check_environment
get_parameters
ask_for_install
download_it
# extract_from_iso
extract_from_tar
add_to_grub
end_message
}

get_parameters () {
##################
# Parameters to change

install_folder="/ISO/HDT"		# ( folder for download iso file from mirros)
memdisk_folder="/boot"		# ( folder for download syslinux-6.03.tar.xz and extract memedisk)

: ${mirrors_1="http://www.hdt-project.org/raw-attachment/wiki/hdt-0.5.0/"}; file_name_1="hdt-0.5.2.iso"
# http://www.hdt-project.org
# http://www.hdt-project.org/raw-attachment/wiki/hdt-0.5.0/hdt-0.5.2.iso

: ${mirrors_2="https://www.kernel.org/pub/linux/utils/boot/syslinux/"}; file_name_2="syslinux-6.03.tar.xz"
# download memdisk from syslinux-6.03.tar.xz
# https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.tar.xz

# qemu -hda myhddimage.img -cdrom hdt.iso -boot d

##################
# advanced parameters to change
MESSAGE=''

# End of advanced parameters to change

##################
}

prepare_check_environment () {

if [ ! -t 0 ]; then				# script is executed outside the terminal
konsole --hold -e "/bin/bash \"$0\" $*"	# execute the script inside a terminal window
exit $?
fi

################## Variables for color terminal
Color_terminal_variables() {
Green=""$'\033[00;32m'"" Red=""$'\033[00;31m'"" White=""$'\033[00;37m'"" Yellow=""$'\033[01;33m'"" Cyan=""$'\033[00;36m'"" Blue=""$'\033[01;34m'"" Magenta=""$'\033[00;35m'""
LGreen=""$'\033[01;32m'"" LRed=""$'\033[01;31m'"" LWhite=""$'\033[01;37m'"" LYellow=""$'\033[01;33m'"" LCyan=""$'\033[01;36m'"" LBlue=""$'\033[00;34m'"" LMagenta=""$'\033[01;35m'""
SmoothBlue=""$'\033[00;38;5;111m'"";Cream=""$'\033[0;38;5;225m'"";Orange=""$'\033[0;38;5;202m'""
LSmoothBlue=""$'\033[01;38;5;111m'"";LCream=""$'\033[1;38;5;225m'"";LOrange=""$'\033[1;38;5;202m'"";Blink=""$'\033[5m'""
if [[ $TERM != *xterm* ]]
then :
	Orange=$LRed LOrange=$LRed LRed=$Red SmoothBlue=$Cyan Blink=""
else :
	LRed=""$'\033[01;38;5;196m'""
fi
Nline=""$'\n'"" Reset=""$'\033[0;0m'"" EraseR=""$'\033[K'"" Back=""$'\b'"" Creturn=""$'\033[\r'"" Ctabh=""$'\033[\t'"" Ctabv=""$'\033[\v'"" SaveP=""$'\033[s'"" RestoreP=""$'\033[u'""
MoveU=""$'\033[1A'"" MoveD=""$'\033[1B'"" MoveR=""$'\033[1C'"" MoveL=""$'\033[1D'""
Linesup () { echo -n ""$'\033['$1'A'"" ;}; Linesdn () { echo ""$'\033['$1'B'"" ;}; Charsfd () { echo -n ""$'\033['$1'C'"" ;}; Charsbk ()  { echo -n ""$'\033['$1'D'"" ;}
}
Color_terminal_variables
#################
	
	echo "$Nline$Green Install Hardware Detection Tool 0.5.2.iso,$Orange Test beta script$Reset"
	echo "$Green # by Leszek Ostachowski (2016) GPL V2$Reset$Nline"
	
	if ! [ $(id -u) = 0 ]; then echo "$Nline$Orange This script must be run with root privileges.$Reset$Nline"
	su -c "/bin/bash \"$0\" $*"
	exit $?
	fi
	
	# Gathering informations about dowload program
	if command -v wget >/dev/null 2>&1; then
		_get_command() { wget -O- --secure-protocol=tlsv1_2 "$@" ; }
	elif command -v curl >/dev/null 2>&1; then
		_get_command() { curl -fL "$@" ; }
	else
		echo "$Red Eroor: This script needs curl or wget, exit$Reset$Nline" >&2
		exit 2
	fi
	
	if [ -z $TMPDIR ]; then TMPDIR=/tmp; fi
	
}

function r_ask() {

	read -p "$1$Red {y}es$SmoothBlue or$Green *{N}o$Orange$Blink ?:$Reset$Yellow *$MoveL$SaveP" -n 1 -r
	
	case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
	    y|yes) echo -n "$RestoreP$EraseR"Yes"$Reset" >&2; echo -n "yes" ;;
	    *)     echo -n "$RestoreP$EraseR"No"$Reset" >&2;  echo -n "no" ;;
	esac
}


ask_for_install () {
	
	if [[ "no" == $(r_ask "$Green You are as root going to download iso file „$file_name_1” from $mirrors_1 and add it to Grub boot menu:$Nline$Cyan ( you need 2 MiB free space left on root of $install_folder folder),$Orange Please answer:") ]]; then
	echo "$Nline$Orange ok, next time$Reset$Nline"; exit 0
	fi
	echo "$Reset$Nline"
}

get_it () {
	
	# Build download command, mirror and path
	local mirror= mirrors="$1" file="$2"
	shift
	for mirror in $mirrors; do
		_get_command "$mirror$file" && return 0
	done
	return 1
}

download_it () {
	
	mkdir -p "$install_folder"
	if ! [ $? = 0 ]; then
		echo "$Red Error: Cannot creat folder $install_folder, exit$Reset$Nline"
		exit 1
	fi
	cd "$install_folder"
	
	if [ -f $file_name_1 ]; then
		echo " file $file_name_1 exist$Reset$Nline"
		if ! [[ "no" == $(r_ask "$Green Download again,$Orange Please answer:") ]]; then
			echo "$Nline$Green Redownload "$mirrors_1" "$file_name_1" =$Reset$Nline"
			get_it "$mirrors_1" "$file_name_1" > "$file_name_1"
			if ! [ $? = 0 ]; then echo "$Nline $Red Error: download, exit 1 $Reset$Nline"; exit 1; else echo "$Green ok"; fi
			MESSAGE+="$Nline$Green $(( mn+=1 )). Redownload $file_name_1 to $install_folder folder $Reset$Nline"
		else
			echo "$Nline$Orange Skipped.$Reset$Nline"
			MESSAGE+="$Nline$Orange $(( mn+=1 )). Skipped redownload $file_name_1 to $install_folder folder $Reset$Nline"
		fi
		
	else
		echo "$Nline$Green Download "$mirrors_1" "$file_name_1" =$Reset$Nline"
		get_it "$mirrors_1" "$file_name_1" > "$file_name_1"
		if ! [ $? = 0 ]; then echo "$Nline $Red Error: download, exit 1 $Reset$Nline"; exit 1; else echo "$Green ok"; fi
		MESSAGE+="$Nline$Green $(( mn+=1 )). Download $file_name_1 to $install_folder folder $Reset$Nline"
		
	fi
	
	chmod 666 $file_name_1
	
	mkdir -p "$memdisk_folder"
	if ! [ $? = 0 ]; then
		echo "$Red Error: Cannot creat folder $memdisk_folder, exit$Reset$Nline"
		exit 1
	fi
	
	if [ -f $memdisk_folder/$file_name_2 ]; then
		echo " file $file_name_2 exist$Reset$Nline"
		if ! [[ "no" == $(r_ask "$Green Download again,$Orange Please answer:") ]]; then
			echo "$Nline$Green Redownload "$mirrors_2" "$file_name_2" =$Reset$Nline"
			get_it "$mirrors_2" "$file_name_2" > "$memdisk_folder/$file_name_2"
			if ! [ $? = 0 ]; then echo "$Nline $Red Error: download, exit 1 $Reset$Nline"; exit 1; else echo "$Green ok"; fi
			MESSAGE+="$Nline$Green $(( mn+=1 )). Redownload $file_name_2 to $memdisk_folder folder $Reset$Nline"
		else
			echo "$Nline$Orange Skipped.$Reset$Nline"
			MESSAGE+="$Nline$Orange $(( mn+=1 )). Skipped redownload $file_name_2 to $memdisk_folder folder $Reset$Nline"
		fi
	else
		echo "$Nline$Green Download "$mirrors_2" "$file_name_2" =$Reset$Nline"
		get_it "$mirrors_2" "$file_name_2" > "$memdisk_folder/$file_name_2"
		if ! [ $? = 0 ]; then echo "$Nline $Red Error: download, exit 1 $Reset$Nline"; exit 1; else echo "$Green ok"; fi
		MESSAGE+="$Nline$Green $(( mn+=1 )). Download $file_name_2 to $memdisk_folder folder $Reset$Nline"
		
	fi
	
}

extract_from_iso () {
	mkdir -p "/mnt/$file_name_1"
	mount -o loop "$install_folder/$file_name_1" "/mnt/$file_name_1"
	cp -fr "/mnt/$file_name_1/" "$install_folder/"
	if ! [ $? = 0 ]; then echo "$Nline $Red Error: Extract from iso, exit 1 $Reset$Nline"; exit 1
	else
	MESSAGE+="$Nline$Green $(( mn+=1 )). Extract from $file_name_1 isolinux folder to $install_folder $Reset$Nline"
	fi
	umount "/mnt/$file_name_1"
	cd "/mnt/"
	rm -df "$file_name_1"
	cd "$install_folder"
}

extract_from_tar () {
	echo "$Nline$Green Extract from $memdisk_folder/$file_name_2 memdisk: $Reset$Nline"
	tar -xvf $memdisk_folder/$file_name_2 syslinux-6.03/bios/memdisk/memdisk
	if ! [ $? = 0 ]; then echo "$Nline $Red Error: Extract from tar, exit 1 $Reset$Nline"; exit 1
	else
	MESSAGE+="$Nline$Green $(( mn+=1 )). Extract memdisk from $file_name_2 $Reset$Nline"
	fi
	mv syslinux-6.03/bios/memdisk/memdisk $memdisk_folder/
	rm -fr syslinux-6.03
}

add_to_grub () {
	
	# Device naming has changed between GRUB Legacy and GRUB. Partitions are numbered from 1 instead of 0 while drives are still numbered from 0,
	# and prefixed with partition-table type. For example, /dev/sda1 would be referred to as (hd0,msdos1) (for MBR) or (hd0,gpt1) (for GPT).
	# ( Old Grub start count disks from 0, partitions from 0)
	# ( New Grub start count disks from 0, partitions from 1)
	
	#  Old Grub
	command=$(whereis -b grub|awk '{print $2}')
	if [[ -f $command ]]
	then
	grub_root_dev=$(echo "find $install_folder/$file_name_1"|grub|grep "(hd"| head -1)
	# Grub "/boot/grub/menu.lst"
	grub_menu_lst=$( cat <<-EOF
	
	title Hardware Detection Tool iso
		root $grub_root_dev
		kernel $memdisk_folder/memdisk iso
		initrd $install_folder/$file_name_1
		
	EOF
	)
	
	echo "$Reset$Nline"
	echo "$Nline$Red Add below lines to /boot/grub/menu.lst : $Nline$Cyan $grub_menu_lst $Reset$Nline"
	if [[ "no" == $(r_ask "$Green Add abowe lines to /boot/grub/menu.lst,$Orange Please answer:") ]]; then
		echo "$Nline$Orange Skipped.$Reset$Nline"
		MESSAGE+="$Nline$Orange $(( mn+=1 )). Skipped add belowe lines to /boot/grub/menu.lst:$Nline $grub_menu_lst $Nline $Reset"
	else
		echo "$grub_menu_lst" >> "/boot/grub/menu.lst"
		echo "$Nline$Orange ok add $Reset$Nline"
		MESSAGE+="$Nline$Green $(( mn+=1 )). Add belowe lines to /boot/grub/menu.lst:$Nline $grub_menu_lst $Nline $Reset"
	fi
	
	fi
	# New Grub
	command1=$(whereis -b grub-mkconfig|awk '{print $2}')
	command2=$(whereis -b grub2-mkconfig|awk '{print $2}')
	
	if [[ -f $command1 ]] || [[ -f $command2 ]] ;then
	# Grub 2 "/etc/grub.d/40_custom"
	grub_40_custom=$( cat <<-EOF
	
	menuentry "Hardware Detection Tool iso" --class cd_boot {
		
		search --file --no-floppy --set=root $install_folder/$file_name_1
		linux16 $memdisk_folder/memdisk iso
		initrd16 $install_folder/$file_name_1
	}
	
	EOF
	)
	
	echo "$Nline$Red Add below lines to /etc/grub.d/40_custom : $Nline$Cyan $grub_40_custom $Reset$Nline"
	if [[ "no" == $(r_ask "$Green Add abowe lines to /etc/grub.d/40_custom and grub-mkconfig -o /boot/grub/grub.cfg,$Orange Please answer:") ]]; then
		echo "$Nline$Orange Skipped.$Reset$Nline"
		MESSAGE+="$Nline$Orange $(( mn+=1 )). Skipped add belowe lines to /etc/grub.d/40_custom:$Nline $grub_40_custom $Nline $Reset"
	else
		echo "$grub_40_custom" >> "/etc/grub.d/40_custom"
		echo "$Nline$Orange ok add $Reset$Nline"
		
		if [[ -f $command1 ]] ;then
			grub-mkconfig -o /boot/grub/grub.cfg
		elif [[ -f $command2 ]] ;then
			grub2-mkconfig -o /boot/grub2/grub.cfg
		fi
		MESSAGE+="$Nline$Green $(( mn+=1 )). Add belowe lines to /etc/grub.d/40_custom:$Nline $grub_40_custom $Nline $Reset"
	fi
	
	fi
}

end_message () {
	
	cat <<-EOF
		$Green
		 Hi,
		 You has successfully:
		 $MESSAGE
		 $Magenta
		 $(( mn+=1 )). To run:$Nline - Reboot and select menuentry Hardware Detection Tool iso ...
		$Green$Blink The end.$Reset
		
	EOF
}
##################
Begin

