#!/bin/bash

# Start tracking time

echo -e "---------------------------------------"
echo -e "SCRIPT STARTING AT $(date +%D\ %r)"
echo -e "---------------------------------------"
START=$(date +%s)

#TG message function

if [ -z "$CHAT_ID" ]; then
export CHAT_ID="348414952 $CHAT_ID";
fi

function message()
{
for f in $CHAT_ID
do
curl -s "https://api.telegram.org/bot${BOT_API}/sendmessage" --data "text=${*}&chat_id=$CHAT_ID&parse_mode=Markdown" > /dev/null
done
}

# Clone kernel setup
git clone https://github.com/AliHasan7671/kernel-setup -b master ksetup

# Environment
export KBUILD_BUILD_USER=AliHasan7671
export KBUILD_BUILD_HOST=Mark85
TOOLCHAIN="$(pwd)/ksetup/toolchains/gcc-4.9/bin/aarch64-linux-android-"
export CROSS_COMPILE="${CCACHE} ${TOOLCHAIN}"
export ARCH=arm64

message "Starting kernel compilation at $(date +%Y%m%d) for mido."

# Start compilation

echo -e " Starting compilation.... "
    make clean O=out/

    make mrproper O=out/

    make mido_defconfig O=out/

    make -j16 O=out

# If the compilation was successful

if [ `ls "out/arch/arm64/boot/Image.gz-dtb" 2>/dev/null | wc -l` != "0" ]
then
   BUILD_RESULT="Compilation successful"
   message "Compilation successful, uploading now!";

    rm ksetup/zipit/*gz-dtb
    rm ksetup/zipit/*.zip
    cp out/arch/arm64/boot/Image.gz-dtb ksetup/zipit
    cd ksetup/zipit
    zip -r9 "JARVIS-mido-$(date +"%Y%m%d"-"%H%M").zip" *

   FINALZIP="$(ls JARVIS-mido-*.zip)"
   size=$(du -sh $FINALZIP | awk '{print $1}')
   md5=$(md5sum $FINALZIP | awk '{print $1}' )

   echo -e " Uploading! "

function push() {
	curl -F document=@$FINALZIP "https://api.telegram.org/bot${BOT_API}/sendDocument" \
			-F chat_id="$CHAT_ID" \
			-F "disable_web_page_preview=true" \
			-F "parse_mode=html"
}
	push
# If compilation failed
else
   BUILD_RESULT="Compilation failed"
   message " Kernel compilation failed.";
   exit 1
fi

# Stop tracking time
END=$(date +%s)
echo -e "-------------------------------------"
echo -e "SCRIPT ENDING AT $(date +%D\ %r)"
echo -e ""
echo -e "${BUILD_RESULT}!"
echo -e "TIME: $(echo $((${END}-${START})) | awk '{print int($1/60)" MINUTES AND "int($1%60)" SECONDS"}')"
echo -e "-------------------------------------"
