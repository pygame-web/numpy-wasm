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

# multi sdk case
if [ -f /pp ]
then
 $PY -m pip install --force https://github.com/cython/cython/releases/download/3.0.8/Cython-3.0.8-py2.py3-none-any.whl
fi

echo $HPY
$HPY -m pip install --force ninja
# /opt/python-wasm-sdk/devices/x86_64/usr/bin/ninja
which ninja

git restore .

patch -p1 <<END
diff --git a/numpy/_core/meson.build b/numpy/_core/meson.build
index 113adb5..4cda911 100644
--- a/numpy/_core/meson.build
+++ b/numpy/_core/meson.build
@@ -478,7 +478,8 @@ int main(void) {
   ''').stdout()
 endif
 if longdouble_format == 'UNKNOWN' or longdouble_format == 'UNDEFINED'
-  error('Unknown long double format of size: ' + cc.sizeof('long double').to_string())
+  warning('Unknown long double format of size: ' + cc.sizeof('long double').to_string())
+  longdouble_format = 'IEEE_DOUBLE_LE'
 endif
 cdata.set10('HAVE_LDOUBLE_' + longdouble_format, true)

END



CC=emcc \
 CXX=em++ \
 EMCC_CFLAGS="-I/opt/python-wasm-sdk/devices/emsdk/usr/include/python${PYBUILD}" \
 $PY -m build \
 -Csetup-args="-Ddisable-optimization=true" \
 -Csetup-args="-Ddisable-threading=true" \
 --no-isolation .

# -Csetup-args="-Ddisable-highway=true" \
# -Csetup-args="-Ddisable-intel-sort=true" \

