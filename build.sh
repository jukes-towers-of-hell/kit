PLACE_NAME="kit.rbxlx"

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[94m"
DEFAULT="\e[0m"

while [ -e $PLACE_NAME.lock ]
do
echo -e "${RED}[WARNING]:${DEFAULT} Place file is open, please close the place before continuing."
read -p "Press Enter to continue."
echo
done

echo -e "${BLUE}--=|       AFTMAN      |=--${DEFAULT}"
aftman install
echo -e $DEFAULT

echo -e "${BLUE}--=|       WALLY       |=--${DEFAULT}"
wally install
echo -e $DEFAULT

echo -e "${BLUE}--=|        ROJO       |=--${GREEN}"
rojo build --output $PLACE_NAME
echo -e $DEFAULT

read -p "Do you want to open the place in Roblox Studio? (y/n) " yn
case $yn in 
	y ) start $PLACE_NAME ;;
    yes ) start $PLACE_NAME ;;
esac