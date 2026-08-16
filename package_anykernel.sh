#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
OUT=${OUT_DIR:-"$ROOT/out"}
IMAGE_DIR="$OUT/arch/arm64/boot"
AK3_DIR=${AK3_DIR:-/home/lunar/AnyKernel3-A325N-ReSukiSU}
ZIP_OUT_DIR=${ZIP_OUT_DIR:-/home/lunar}
KSU_DIR="$ROOT/KernelSU"

[ -f "$IMAGE_DIR/Image" ] || { echo "ERROR: Image not found: $IMAGE_DIR/Image" >&2; exit 1; }
[ -f "$IMAGE_DIR/Image.gz" ] || { echo "ERROR: Image.gz not found: $IMAGE_DIR/Image.gz" >&2; exit 1; }
[ -f "$AK3_DIR/anykernel.sh" ] || { echo "ERROR: AnyKernel dir invalid: $AK3_DIR" >&2; exit 1; }
[ -d "$KSU_DIR/.git" ] || [ -f "$KSU_DIR/.git" ] || { echo "ERROR: KernelSU git repo not found" >&2; exit 1; }

TAG=$(git -C "$KSU_DIR" describe --abbrev=0 --tags 2>/dev/null || echo v4.1.0)
SHA=$(git -C "$KSU_DIR" rev-parse --short=8 HEAD)
COUNT=$(git -C "$KSU_DIR" rev-list --count HEAD)
KSU_CODE=$((30700 + COUNT))
SUSFS=$(sed -n 's/^#define SUSFS_VERSION "\([^"]*\)"/\1/p' "$ROOT/include/linux/susfs.h" | head -n1)
[ -n "$SUSFS" ] || { echo "ERROR: SUSFS version not found" >&2; exit 1; }
SUSFS_DISPLAY=${SUSFS#v}
KERNEL_STRING="A325N ReSukiSU ${TAG}(${KSU_CODE}) SUSFS ${SUSFS_DISPLAY}"
ZIP_NAME="A325N-ReSukiSU-${TAG}-${KSU_CODE}-SUSFS-${SUSFS}-stable.zip"
ZIP_PATH="$ZIP_OUT_DIR/$ZIP_NAME"

printf '%s\n' "ReSukiSU : $TAG-$SHA ($KSU_CODE)"
printf '%s\n' "SUSFS    : $SUSFS"
printf '%s\n' "Source   : $IMAGE_DIR"
printf '%s\n' "AnyKernel: $AK3_DIR"

cp -f "$IMAGE_DIR/Image" "$AK3_DIR/Image"
cp -f "$IMAGE_DIR/Image.gz" "$AK3_DIR/Image.gz"
sed -i "s|^kernel\.string=.*|kernel.string=$KERNEL_STRING|" "$AK3_DIR/anykernel.sh"

mkdir -p "$ZIP_OUT_DIR"
rm -f "$ZIP_PATH"
(
  cd "$AK3_DIR"
  zip -qr "$ZIP_PATH" . \
    -x '.git/*' '.git' '*.zip' '*~' '*.bak'
)

printf '%s\n' "Created  : $ZIP_PATH"
sha256sum "$ZIP_PATH"
printf '%s\n' "Image.gz : $(sha256sum "$AK3_DIR/Image.gz" | awk '{print $1}')"
