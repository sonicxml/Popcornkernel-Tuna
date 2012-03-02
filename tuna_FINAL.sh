#!/bin/bash

echo -n "What Version is This? (in the format v___) "
read -e VERSION

echo -n "What Subversion is This? "
read -e SUB


#Configuration
DATE=$(date +"%m-%d-%Y")
LCD=$"~/Android/Kernel/AnyKernel"
DEVICE=$"Galaxy Nexus"
PACKAGE=$"Popcorn_Kernel-$VERSION-$SUB-unsigned.zip"
PACKAGE_SIGNED=$"Popcorn-Kernel-$VERSION-$SUB.zip"
HOST=$"rootingmydroid.com" 
USER=$"sonicxml@droidvicious.com"            
PASS=$"***********" 
LCD=$"~/Dropbox/Public/PopcornKernel/$VERSION/$SUB/"         
echo "
 your version is: $VERSION $SUB
"

 echo "
	The popcorn has started cooking...
"

cd ~/Android/Kernel/omap
make clean && make mrproper
find -type f -name "*~" -print -exec rm {} \;
make popcorn_defconfig

time make -j9 CROSS_COMPILE=/home/sonicxml/ndk/toolchains/arm-linux-androideabi-4.4.3/prebuilt/linux-x86/bin/arm-linux-androideabi-

if [ -f ~/Android/Kernel/omap/arch/arm/boot/zImage ];
     then
         echo "
 Popcorn done! Time to place the popcorn in the container...
"
     else
       echo "
 You fail at making popcorn. Try again.
"
         exit 0
 fi
cd ..
rm -rf ~/Android/Kernel/AnyKernel/
git clone https://github.com/sonicxml/AnyKernel.git
rm  ~/Android/Kernel/AnyKernel/kernel/zImage
echo " 
 Placing the popcorn in the container...
"
cp ~/Android/Kernel/omap/arch/arm/boot/zImage ~/Android/Kernel/AnyKernel/kernel/zImage
mkdir ~/Android/Kernel/AnyKernel/system
mkdir ~/Android/Kernel/AnyKernel/system/lib
mkdir ~/Android/Kernel/AnyKernel/system/lib/modules
mkdir ~/Android/Kernel/AnyKernel/data
mkdir ~/Android/Kernel/AnyKernel/data/cron
mkdir ~/Android/Kernel/AnyKernel/system/etc
mkdir ~/Android/Kernel/AnyKernel/system/etc/init.d
cp ~/Android/Kernel/omap/crypto/ansi_cprng.ko ~/Android/Kernel/AnyKernel/system/lib/modules/ansi_cprng.ko
cp ~/Android/Kernel/omap/drivers/net/tun.ko ~/Android/Kernel/AnyKernel/system/lib/modules/tun.ko
cp ~/Android/Kernel/omap/drivers/rpmsg/rpmsg_client_sample.ko ~/Android/Kernel/AnyKernel/system/lib/modules/rpmsg_client_sample.ko
cp ~/Android/Kernel/omap/drivers/rpmsg/rpmsg_server_sample.ko ~/Android/Kernel/AnyKernel/system/lib/modules/rpmsg_server_sample.ko
cp ~/Android/Kernel/omap/drivers/scsi/scsi_wait_scan.ko ~/Android/Kernel/AnyKernel/system/lib/modules/scsi_wait_scan.ko
cp ~/Android/Kernel/omap/crypto/md4.ko ~/Android/Kernel/AnyKernel/system/lib/modules/md4.ko
cp ~/Android/Kernel/omap/fs/cifs/cifs.ko ~/Android/Kernel/AnyKernel/system/lib/modules/cifs.ko
cp ~/Android/Kernel/omap/updater-script ~/Android/Kernel/AnyKernel/META-INF/com/google/android/updater-script
cp ~/Android/Kernel/omap/root ~/Android/Kernel/AnyKernel/data/cron/root
cp ~/Android/Kernel/omap/99sonic ~/Android/Kernel/AnyKernel/system/etc/init.d/99sonic
cp ~/Android/Kernel/omap/sysctl.conf ~/Android/Kernel/AnyKernel/system/etc/sysctl.conf
cd AnyKernel 
zip -r $PACKAGE data system kernel META-INF 

echo " 
 Adding butter and sealing your container to protect your beautiful popcorn...
"
java -classpath ~/AndroidSigner/testsign.jar testsign ~/Android/Kernel/AnyKernel/$PACKAGE ~/Android/Kernel/AnyKernel/$PACKAGE_SIGNED
rm ~/Android/Kernel/AnyKernel/$PACKAGE
md5sum $PACKAGE_SIGNED > $PACKAGE_SIGNED.md5sum
if [ -d ~/Dropbox/Public/PopcornKernel/$VERSION/ ]
     then
	echo "this must be another trial of the same version"
	mkdir ~/Dropbox/Public/PopcornKernel/$VERSION/$SUB/
	cp ~/Android/Kernel/AnyKernel/$PACKAGE_SIGNED ~/Dropbox/Public/PopcornKernel/$VERSION/$SUB/$PACKAGE_SIGNED
	mkdir ~/Dropbox/Public/PopcornKernel/$VERSION/$SUB/md5sum/
	cp ~/Android/Kernel/AnyKernel/$PACKAGE_SIGNED.md5sum ~/Dropbox/Public/PopcornKernel/$VERSION/$SUB/md5sum/$PACKAGE_SIGNED.md5sum
	echo " 
	Popcorn done and ready to eat!
	"
     else
	
	mkdir ~/Dropbox/Public/PopcornKernel/$VERSION/
	mkdir ~/Dropbox/Public/PopcornKernel/$VERSION/$SUB/
	cp ~/Android/Kernel/AnyKernel/$PACKAGE_SIGNED ~/Dropbox/Public/PopcornKernel/$VERSION/$SUB/$PACKAGE_SIGNED
	mkdir ~/Dropbox/Public/PopcornKernel/$VERSION/$SUB/md5sum/
	cp ~/Android/Kernel/AnyKernel/$PACKAGE_SIGNED.md5sum ~/Dropbox/Public/PopcornKernel/$VERSION/$SUB/md5sum/$PACKAGE_SIGNED.md5sum
	echo " 
	Popcorn done and ready to eat!
	"    
fi
ftp -inv $HOST <<EOT
ascii
user $USER $PASS 
cd /PopcornKernel-Gnexus/
lcd $LCD
put $PACKAGE_SIGNED
EOT

echo "
generating goo.gl link...

"
URL=$"http://droidvicious.com/ROMS/sonicxml/PopcornKernel-Gnexus/$PACKAGE_SIGNED"
curl -s -d url=$URL http://goo.gl/api/url | sed -n "s/.*:\"\([^\"]*\).*/\1/p";
echo "<-- Download Link
"
curl -s -d url=$URL http://goo.gl/api/url | sed -n "s/.*:\"\([^\"]*\).*/\1/p";
echo "+ <-- Use this link for Statistics
"
echo "

md5:"
cat ~/Dropbox/Public/PopcornKernel/$VERSION/$SUB/md5sum/$PACKAGE_SIGNED.md5sum
echo "
	Done!
"
