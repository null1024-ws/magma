#!/bin/bash
set -e

# Always apply setup patches
find "$TARGET/patches/setup" -name "*.patch" | while read patch; do
    echo "Applying setup patch: $patch"
    name=${patch##*/}
    name=${name%.patch}
    sed "s/%MAGMA_BUG%/$name/g" "$patch" | patch -p1 -d "$TARGET/repo"
done

# Convert BUGS_TO_PATCH into array
IFS=' ' read -r -a BUGS_ARRAY <<< "$BUGS_TO_PATCH"

# Conditionally apply bug patches
if [ "${#BUGS_ARRAY[@]}" -gt 0 ]; then
    for bug in "${BUGS_ARRAY[@]}"; do
        patch="$TARGET/patches/bugs/$bug.patch"
        if [ -f "$patch" ]; then
            echo "Applying bug patch: $patch"
            sed "s/%MAGMA_BUG%/$bug/g" "$patch" | patch -p1 -d "$TARGET/repo"
        else
            echo "Warning: Patch for $bug not found!"
        fi
    done
else
    echo "No bug patches specified. Skipping bugs/ patches."
fi
