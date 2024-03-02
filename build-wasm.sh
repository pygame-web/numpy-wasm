#!/bin/bash


if which patchelf
then
    echo -n
else
    sudo apt-get install patchelf
fi

SDKROOT=${SDKROOT:-/opt/python-wasm-sdk}

export PYBUILD=${PYBUILD:-3.13}

. ${CONFIG:-${SDKROOT}/config}

PY=${SDKROOT}/python3-wasm

git restore .
git pull

patch -p1 <<END
diff --git a/numpy/_core/meson.build b/numpy/_core/meson.build
index 113adb5f7..0e9db9bfb 100644
--- a/numpy/_core/meson.build
+++ b/numpy/_core/meson.build
@@ -394,7 +394,7 @@ endforeach
 # https://github.com/numpy/numpy/blob/eead09a3d02c09374942cdc787c0b5e4fe9e7472/numpy/core/setup_common.py#L264-L434
 # This port is in service of solving gh-23972
 # as well as https://github.com/mesonbuild/meson/issues/11068
-longdouble_format = meson.get_external_property('longdouble_format', 'UNKNOWN')
+longdouble_format = 'IEEE_QUAD_LE'
 if longdouble_format == 'UNKNOWN'
   longdouble_format = meson.get_compiler('c').run(
 '''
END

echo "MESON=$(which meson)"
CC=emcc CXX=em++ \
 EMCC_CFLAGS="-I${SDKROOT}/devices/emsdk/usr/include/python${PYBUILD}" \
 $PY -m build \
 -Csetup-args="-Ddisable-optimization=true" \
 -Csetup-args="-Ddisable-threading=true" \
 -Csetup-args="-Dmkl-threading=false" \
 -Csetup-args="-Dallow-noblas=true" \
 -Csetup-args="--cross-file=/data/git/numpy-wasm/meson-python-cross-file.ini" \
 --no-isolation .

# -Csetup-args="-Ddisable-highway=true" \
# -Csetup-args="-Ddisable-intel-sort=true" \

