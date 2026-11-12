#!/bin/bash
set -e

echo "=== WONDERLAND // BUILD SYSTEM ==="

# 1. Build Rust core FFI library
if [ -f "core/Cargo.toml" ]; then
	echo "Compiling Rust core static library..."
	cargo build --manifest-path core/Cargo.toml --release

	# Ensure staging directory exists
	mkdir -p ui/Libs

	# Check both core-local and workspace-root target directories for the static library
	SRC_LIB=""
	if [ -f "core/target/release/libwonderland_core.a" ]; then
		SRC_LIB="core/target/release/libwonderland_core.a"
	elif [ -f "target/release/libwonderland_core.a" ]; then
		SRC_LIB="target/release/libwonderland_core.a"
	fi

	if [ -z "$SRC_LIB" ]; then
		echo "Error: Expected static library 'libwonderland_core.a' could not be found in target directories."
		exit 1
	fi

	# Copy to ui/Libs for Swift Package Manager linking
	cp -f "$SRC_LIB" ui/Libs/libwonderland_core.a
	echo "Static library staged successfully from $SRC_LIB to ui/Libs/"

	# Verify symbol existence using Rust toolchain's llvm-nm (bypasses Xcode toolchain LLVM mismatch)
	RUST_NM="$(rustc --print sysroot)/bin/llvm-nm"
	if [ -x "$RUST_NM" ]; then
		if "$RUST_NM" -g ui/Libs/libwonderland_core.a | grep -q "wonderland_verify_and_inspect_crystal"; then
			echo "Symbol verification PASSED: wonderland_verify_and_inspect_crystal found."
		else
			echo "Error: Symbol 'wonderland_verify_and_inspect_crystal' NOT found in static library!"
			exit 1
		fi
	else
		echo "Warning: llvm-nm not found in rustc sysroot, skipping symbol verification."
	fi
elif [ -f "Cargo.toml" ]; then
    cargo build --release
fi

# 2. Build Swift Dashboard via Swift Package Manager
echo "Building WonderlandApp via Swift PM..."
swift build -c release

echo "=== BUILD COMPLETE ==="
echo "Artifact ready: .build/release/WonderlandApp"
