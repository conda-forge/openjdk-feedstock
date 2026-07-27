#!/bin/bash
set -exuo pipefail

# Regression test for #218: on linux, jmods are intentionally not shipped
# (see commit 2d84380, "Linux now uses JEP 493"), so jlink must be able to
# link custom run-time images directly from this run-time image instead.

echo "=== Running jlink linkable-runtime regression test (#218) ==="

if ! "${JAVA_HOME}/bin/jlink" --help | grep -q "Linking from run-time image enabled"; then
  echo "ERROR: jlink does not report linkable-runtime support enabled (see #218)"
  "${JAVA_HOME}/bin/jlink" --help
  exit 1
fi
echo "-> jlink reports linkable-runtime support enabled"

JLINK_TEST_IMAGE=$(mktemp -d)/jlink-test-image
# jlink's run-time image integrity check flags files (e.g. bin/keytool) as
# modified relative to what the JDK build recorded. Confirmed by comparing
# the raw build output against the packaged binaries: the unpackaged
# bin/java has RPATH [$ORIGIN:$ORIGIN/../lib], while the packaged one has
# RPATH [$ORIGIN/../..:$ORIGIN:$ORIGIN/../lib] - rattler-build's
# binary_relocation post-processing (see `dynamic_linking` in recipe.yaml)
# adds the extra $ORIGIN/../.. entry after the JDK build has already
# recorded its integrity hashes, which is what jlink flags. Running jlink
# directly against the raw build output produces no such warnings.
# --ignore-modified-runtime demotes this to a warning, since the change is
# this expected, packaging-time RPATH patch (required for the package to
# work when installed into a user's actual environment prefix), not a
# change to security-relevant content.
"${JAVA_HOME}/bin/jlink" --add-modules java.base --ignore-modified-runtime --output "${JLINK_TEST_IMAGE}"
# jlink does not bundle non-JDK OS libraries (e.g. zlib) into the image, and
# the copied bin/java's $ORIGIN-relative RPATH does not reach $PREFIX/lib
# from the jlinked image's shallower layout. Set LD_LIBRARY_PATH so this
# test resolves libz.so.1 the same way the unpackaged JDK does.
LD_LIBRARY_PATH="$PREFIX/lib:${LD_LIBRARY_PATH:-}" "$JLINK_TEST_IMAGE/bin/java" -version
rm -rf "${JLINK_TEST_IMAGE}"

echo "=== jlink linkable-runtime regression test (#218) PASSED ==="
