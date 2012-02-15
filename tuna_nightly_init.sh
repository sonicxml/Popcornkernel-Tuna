#!/bin/bash

#Configuration
DATE=$(date +"%m-%d-%Y")
HOST=$"jdkoreclipse.net"
UPDIR=$"mirror/kernel/tuna"
PACKAGE=$"jdkernel_tuna_nightly_$DATE.zip"
PACKAGE_SIGNED=$"jdkernel_tuna_nightly_signed_$DATE.zip"
LCD=$"~/tuna/omap/AnyKernel"
ServerCD=$"public_html/mirror/kernel/tuna"
DEVICE=$"Galaxy Nexus"

 echo "
 === Welcome to JDBOT! Kernel build has initiated successfully! ===
"

cd ~/tuna/omap
rm -rf ~/tuna/omap/AnyKernel/
make clean
make tuna_defconfig
make -j9 ARCH=arm CROSS_COMPILE=~/android/4.4.4/bin/arm-none-eabi-
if [ -f ~/tuna/omap/arch/arm/boot/zImage ];
     then
         echo "
 === zImage found. Onward to packaging. ===
"
     else
       echo "
 === zImage not found. Fix your code and re-compile. ===
"
         exit 0
 fi
git clone https://github.com/sonicxml/AnyKernel.git -b omap
rm  ~/tuna/omap/AnyKernel/kernel/zImage
cp ~/tuna/omap/arch/arm/boot/zImage ~/tuna/omap/AnyKernel/kernel/zImage
cd AnyKernel 
echo " 
=== Packing files. ===
"
zip -r $PACKAGE system kernel META-INF 
echo " 
=== Signing Zip. ===
"
java -jar ~/kernelsign/signapk.jar ~/kernelsign/testkey.x509.pem ~/kernelsign/testkey.pk8 ~/tuna/omap/AnyKernel/$PACKAGE ~/tuna/omap/AnyKernel/$PACKAGE_SIGNED
rm ~/tuna/omap/AnyKernel/$PACKAGE
md5sum $PACKAGE_SIGNED > $PACKAGE_SIGNED.md5sum
echo " 
=== DONE! ===
"
exit


