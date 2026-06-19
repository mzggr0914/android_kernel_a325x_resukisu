#!/bin/sh
set -eu
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/root/zyc-clang/bin:$PATH
export TC=/root/zyc-clang
export HOSTCC=gcc
export HOSTLD=/usr/bin/ld
export CROSS_COMPILE=$TC/bin/aarch64-linux-gnu-
export LD=$TC/bin/ld.lld
export OBJCOPY=$TC/bin/llvm-objcopy
export AS=$TC/bin/llvm-as
export NM=$TC/bin/llvm-nm
export STRIP=$TC/bin/llvm-strip
export OBJDUMP=$TC/bin/llvm-objdump
export READELF=$TC/bin/llvm-readelf
export CC=$TC/bin/clang
export ARCH=arm64
export KCFLAGS=' -w -pipe -O3'
export KCPPFLAGS=' -O3'
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y
CFGDIR=arch/arm64/configs
rm -rf out "$CFGDIR/compiled_defconfig"
make -C "$PWD" O="$PWD/out" clean -j$(nproc)
make -C "$PWD" O="$PWD/out" mrproper -j$(nproc)
cat "$CFGDIR/mt6768_slm_defconfig" "$CFGDIR/a32.config" "$CFGDIR/battery.config" "$CFGDIR/ksu-a325n-common.config" > "$CFGDIR/compiled_defconfig"
cat >> "$CFGDIR/compiled_defconfig" <<'EOF'
# CONFIG_ALWAYS_ENFORCE is not set
CONFIG_ALWAYS_PERMISSIVE=y
CONFIG_MTK_GPU_VERSION="mali bifrost r25p0"
EOF
make -C "$PWD" O="$PWD/out" -j$(nproc) compiled_defconfig
make -s -C "$PWD" O="$PWD/out" -j$(nproc)
