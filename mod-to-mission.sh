DST_DIR=$1

if [ "$DST_DIR" == "" ]; then
  echo "./$0 <DEST_DIR>"
  exit 1
fi

cat > $DST_DIR/fn_A3A_patches.sqf <<EOF
if !(isClass (missionConfigFile/"A3A")) exitWith {};//safeguard to block running on none antistasi missions

#include "\x\A3A\addons\core\script_component.hpp"
FIX_LINE_NUMBERS()

Info("patching A3A functions");

EOF

git diff btr-base \
  | grep '+++' \
  | awk 'BEGIN{FS="b/"}{print $2}' \
  | grep ".sqf" \
  | awk "{system(\"./file-to-mission.sh \" \$1 \" \" \"$DST_DIR\")}"

