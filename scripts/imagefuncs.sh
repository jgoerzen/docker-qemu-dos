# Note: these scripts are not race-safe!

# Take a gzipped qcow2 file as $1, and prepare to work on it.
# Creates a temp image, puts location in TEMPIMAGE
prepimageedit() {
  TEMPIMAGE="/tmp/imgtemp.$$.raw"
  zcat "$1" > "/tmp/imgtemp.$$.qcow2"
  qemu-img convert -f qcow2 -O raw "/tmp/imgtemp.$$.qcow2" "$TEMPIMAGE"
  rm "/tmp/imgtemp.$$.qcow2"
  echo "drive c: file=\"TEMPIMAGE\" partition=1" > /etc/mtools.conf
}

# Finish working on a temp image, winding up saving it uncompress to
# the "$1" location.
finishimageedit() {
  qemu-img convert -f raw -O qcow2 "$TEMPIMAGE" "$1"
  rm "$TEMPIMAGE"
  # wipe out the line from mtools, just in case.
  echo > /etc/mtools.conf
  unset TEMPIMAGE
}

# Prepare to edit an image file with sed.  Takes $1 as the mtools path (beginning with C:)
# Stores the temporary name in TEMPSED
prepsed() {
  TEMPSED="/tmp/tempsed.$$"
  TEMPSEDORIGIN="$1"
  mcopy "$1" "$TEMPSED"
}

# Finish up the sed.  No need to give it the original filename back.
finishsed() {
  mcopy "$TEMPSED" "$TEMPSEDORIGIN"
  rm "$TEMPSED"
  unset TEMPSED
  unset TEMPSEDORIGIN
}

 
