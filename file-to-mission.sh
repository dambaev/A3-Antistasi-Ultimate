FILE=$1
DST_DIR=$2

RAW_ROOT=$(dirname $FILE)
RELATIVE_ROOT=$RAW_ROOT
ROOT=${RAW_ROOT//\//\\}
echo "RELATIVE_ROOT = $RELATIVE_ROOT"


FN_NAME=$(basename $FILE | awk 'BEGIN{FS=".sqf"}{print $1}')
WOFN_NAME=$(basename $FN_NAME | awk 'BEGIN{FS="fn_"}{print $2}')

if [ "$DST_DIR" == "" ]; then
  exit 0
fi

mkdir -p $DST_DIR/$RAW_ROOT

cp $FILE $DST_DIR/$FILE

echo $DST_DIR/$FILE
grep -F "#include \".." $DST_DIR/$FILE | while IFS= read -r INCLUDE; do
  echo "INCLUDE = $INCLUDE"
  UPPER_LEVELS_COUNT=$(echo $INCLUDE | grep -Fo ".." | wc -l)
  echo "UPPER_LEVELS_COUNT = $UPPER_LEVELS_COUNT"
  RELATIVE_ROOT=$RAW_ROOT
  for LEVEL in $(seq 2 $UPPER_LEVELS_COUNT); do
    echo sed -i 's=#include "..\\=#include "=g' $DST_DIR/$FILE
    sed -i 's=#include "..\\=#include "=g' $DST_DIR/$FILE
    echo "RELATIVE_ROOT=$(dirname $RELATIVE_ROOT)"
    RELATIVE_ROOT=$(dirname $RELATIVE_ROOT)
  done
  echo RELATIVE_ROOT=$(dirname $RELATIVE_ROOT)
  RELATIVE_ROOT=$(dirname $RELATIVE_ROOT)
  INCLUDE_ROOT="\\\\x\\\\${RELATIVE_ROOT//\//\\\\}"
  echo sed -i "s=#include \"..=#include \"$INCLUDE_ROOT=g" $DST_DIR/$FILE
  sed -i "s=#include \"..=#include \"$INCLUDE_ROOT=g" $DST_DIR/$FILE
done

# sed -i "s=#include \"..=#include \"$INCLUDE_ROOT\\\\..=g" $DST_DIR/$FILE

cat >> $DST_DIR/fn_A3A_patches.sqf <<EOF
["$ROOT\\", "A3A_fnc_", [["$WOFN_NAME", "$FN_NAME"]], true] call BIS_fnc_loadFunctions;
["A3A_fnc_$WOFN_NAME"] call BIS_fnc_recompile;

EOF

