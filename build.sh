PLACE_NAME="kit.rbxlx"

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[94m"
DEFAULT="\e[0m"

if [ -e $PLACE_NAME.lock ]
then
echo -e "${RED}[WARNING]:${DEFAULT} Place file is open, please close the place before continuing."
read -p "Press Enter to continue."
echo
fi

if [ -e $PLACE_NAME ]
then
rm $PLACE_NAME
fi

echo -e "${BLUE}--=|    AFTMAN    |=--${DEFAULT}"
aftman install
echo -e $DEFAULT

echo -e "${BLUE}--=|     ROJO     |=--${GREEN}"
rojo build --output $PLACE_NAME
echo -e $DEFAULT

echo -e "${BLUE}--=|     LUNE     |=--${DEFAULT}"
lune assets/unpack.lua $PLACE_NAME
echo -e $DEFAULT

read -p "Do you want to open the place in Roblox Studio? (y/n) " yn
case $yn in 
	y ) start $PLACE_NAME ;;
    yes ) start $PLACE_NAME ;;
esac