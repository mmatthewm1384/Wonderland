
# ============================================================================
# WONDERLAND PLATFORM MAKEFILE
#
# GNU Make 3.81 compatible
# Host: macOS / Apple Silicon
# Spark build runtime: Colima orbit / containerd / Debian Bookworm ARM64
#
# Safety principles:
#   - Explicit workspace root precedence
#   - Digest-pinned build image
#   - Container-internal rootfs staging
#   - Validated artifacts before publication
#   - No implicit destruction of existing artifacts
#   - Process identity checks before signaling vfkit
#   - No fabricated daemon lifecycle
# ============================================================================

.DEFAULT_GOAL := all

SHELL := /bin/sh

# ----------------------------------------------------------------------------
# Workspace root resolution
#
# Precedence:
#   WL_ROOT -> WL_HOME -> WONDERLAND_ROOT -> Makefile directory
# ----------------------------------------------------------------------------

WL_ROOT ?=
WL_HOME ?=
WONDERLAND_ROOT ?=

MAKEFILE_DIR := $(shell cd "$(dir $(lastword $(MAKEFILE_LIST)))" 2>/dev/null && pwd -P)

ifneq ($(strip $(WL_ROOT)),)
ROOT_DIR := $(shell cd "$(WL_ROOT)" 2>/dev/null && pwd -P)
else
ifneq ($(strip $(WL_HOME)),)
ROOT_DIR := $(shell cd "$(WL_HOME)" 2>/dev/null && pwd -P)
else
ifneq ($(strip $(WONDERLAND_ROOT)),)
ROOT_DIR := $(shell cd "$(WONDERLAND_ROOT)" 2>/dev/null && pwd -P)
else
ROOT_DIR := $(MAKEFILE_DIR)
endif
endif
endif

# ----------------------------------------------------------------------------
# Spark build configuration
# ----------------------------------------------------------------------------

BUILD_CANDIDATE ?= vm-candidate-20261024-01

BUILD_PARENT := $(ROOT_DIR)/images/spark-debian/build
BUILD_DIR := $(BUILD_PARENT)/$(BUILD_CANDIDATE)

LOG_DIR := $(ROOT_DIR)/logs/spark-debian

ROOTFS_PATH := $(BUILD_DIR)/debian-bookworm-vm-rootfs.ext4
KERNEL_PATH := $(BUILD_DIR)/vmlinuz
INITRD_PATH := $(BUILD_DIR)/initrd.img
DATA_DISK := $(BUILD_DIR)/data.ext4

BUILD_STAMP := $(BUILD_DIR)/build-manifest.txt
CHECKSUM_FILE := $(BUILD_DIR)/checksums.sha256

# Verified from the orbit namespace image inspection.
BASE_IMAGE := debian@sha256:99c0b25c46d0214d5a2091092e7908907dcaecd6a962cde0ac700acee222b6f3

CONTAINER_NAMESPACE ?= orbit

NERDCTL ?= nerdctl
VFKit ?= vfkit

ROOTFS_SIZE ?= 4G
DATA_DISK_SIZE ?= 1G

CPUS ?= 2
MEMORY_MB ?= 2048

# Require a host safety margin before creating large artifacts.
MIN_HOST_FREE_KB ?= 8388608

PID_FILE := $(LOG_DIR)/vfkit.pid
SERIAL_LOG := $(LOG_DIR)/vm-serial.log
VFKit_LOG := $(LOG_DIR)/vfkit.log

# ----------------------------------------------------------------------------
# Python configuration
# ----------------------------------------------------------------------------

PYTHON ?= $(ROOT_DIR)/.venv/bin/python
PYTEST ?= $(PYTHON) -m pytest

CONTROL_AUDIT_LOG ?= $(ROOT_DIR)/crystal_audit.log

# ----------------------------------------------------------------------------
# Phony targets
# ----------------------------------------------------------------------------

.PHONY: all
.PHONY: vm-validate vm-artifacts vm-build vm-check-artifacts
.PHONY: start-spark-debian stop-spark-debian status-spark-debian
.PHONY: launch-ssh clean
.PHONY: setup-venv benchmark
.PHONY: taylorzone-deploy
.PHONY: control-test control-daemon-start control-daemon-stop
.PHONY: control-audit-tail

all: vm-artifacts

# ============================================================================
# HOST VALIDATION
# ============================================================================

vm-validate:
	@set -eu; \
	test -n "$(ROOT_DIR)" || { echo "FAIL: Workspace root is unresolved"; exit 1; }; \
	test -d "$(ROOT_DIR)" || { echo "FAIL: Invalid workspace root: $(ROOT_DIR)"; exit 1; }; \
	case "$(BUILD_CANDIDATE)" in \
		""|.|..|*/*) echo "FAIL: Invalid BUILD_CANDIDATE"; exit 1 ;; \
	esac; \
	command -v "$(NERDCTL)" >/dev/null 2>&1 || { echo "FAIL: nerdctl unavailable"; exit 1; }; \
	command -v "$(VFKit)" >/dev/null 2>&1 || { echo "FAIL: vfkit unavailable"; exit 1; }; \
	command -v zsh >/dev/null 2>&1 || { echo "FAIL: zsh unavailable"; exit 1; }; \
	command -v shasum >/dev/null 2>&1 || { echo "FAIL: shasum unavailable"; exit 1; }; \
	command -v python3 >/dev/null 2>&1 || { echo "FAIL: python3 unavailable"; exit 1; }; \
	AVAILABLE_KB=$$(df -Pk "$(ROOT_DIR)" | awk 'NR == 2 {print $$4}'); \
	test -n "$$AVAILABLE_KB" || { echo "FAIL: Cannot determine host free space"; exit 1; }; \
	if [ "$$AVAILABLE_KB" -lt "$(MIN_HOST_FREE_KB)" ]; then \
		echo "FAIL: Host free space below safety threshold"; \
		echo "Available: $${AVAILABLE_KB} KiB"; \
		echo "Required:  $(MIN_HOST_FREE_KB) KiB"; \
		exit 1; \
	fi; \
	echo "PASS: Workspace root: $(ROOT_DIR)"; \
	echo "PASS: Candidate: $(BUILD_CANDIDATE)"; \
	echo "PASS: Host prerequisites"; \
	echo "PASS: Host free-space safety threshold"

# ============================================================================
# SPARK ARTIFACT ORCHESTRATION
# ============================================================================

vm-artifacts: vm-validate
	@set -eu; \
	if [ ! -s "$(ROOTFS_PATH)" ] || \
	   [ ! -s "$(KERNEL_PATH)" ] || \
	   [ ! -s "$(INITRD_PATH)" ] || \
	   [ ! -s "$(BUILD_STAMP)" ] || \
	   [ ! -s "$(CHECKSUM_FILE)" ]; then \
		$(MAKE) vm-build; \
	else \
		echo "PASS: Existing candidate artifacts detected"; \
	fi
	@$(MAKE) vm-check-artifacts

# ============================================================================
# SPARK IMAGE BUILD
#
# Rootfs staging remains inside the container at /tmp/rootfs.
# Only final artifacts are written to the host-mounted staging directory.
# ============================================================================

vm-build: vm-validate
	@set -eu; \
	mkdir -p "$(BUILD_PARENT)" "$(LOG_DIR)"; \
	if [ -L "$(BUILD_DIR)" ]; then \
		echo "FAIL: Candidate directory is a symlink"; \
		exit 1; \
	fi; \
	if [ -d "$(BUILD_DIR)" ]; then \
		CONTENTS=$$(find "$(BUILD_DIR)" -mindepth 1 -maxdepth 1 -print -quit); \
		if [ -n "$$CONTENTS" ]; then \
			echo "FAIL: Candidate directory is not empty"; \
			echo "Refusing to overwrite: $(BUILD_DIR)"; \
			exit 1; \
		fi; \
	fi; \
	STAGE=$$(mktemp -d "$(BUILD_PARENT)/.$(BUILD_CANDIDATE).stage.XXXXXX"); \
	trap 'rm -rf "$$STAGE"' EXIT HUP INT TERM; \
	echo "============================================================"; \
	echo "BUILDING DEBIAN BOOKWORM ARM64 SPARK"; \
	echo "============================================================"; \
	echo "Image: $(BASE_IMAGE)"; \
	echo "Namespace: $(CONTAINER_NAMESPACE)"; \
	echo "Staging: $$STAGE"; \
	$(NERDCTL) --namespace "$(CONTAINER_NAMESPACE)" run --rm --privileged \
		--memory 1536m \
		--cpus 2 \
		-v "$$STAGE:/build" \
		-e ROOTFS_SIZE="$(ROOTFS_SIZE)" \
		"$(BASE_IMAGE)" bash -euc '\
			set -Eeuo pipefail; \
			export DEBIAN_FRONTEND=noninteractive; \
			R=/tmp/rootfs; \
			mkdir -p "$$R"; \
			apt-get update -qq; \
			apt-get install -y -qq --no-install-recommends \
				debootstrap e2fsprogs gzip; \
			debootstrap --arch=arm64 bookworm \
				"$$R" http://deb.debian.org/debian; \
			printf "%s\n" \
				"deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware" \
				> "$$R/etc/apt/sources.list"; \
			mkdir -p "$$R/proc" "$$R/sys" "$$R/dev/pts"; \
			cleanup_mounts() { \
				umount "$$R/dev/pts" 2>/dev/null || true; \
				umount "$$R/dev" 2>/dev/null || true; \
				umount "$$R/sys" 2>/dev/null || true; \
				umount "$$R/proc" 2>/dev/null || true; \
			}; \
			trap cleanup_mounts EXIT; \
			mount -t proc proc "$$R/proc"; \
			mount -t sysfs sys "$$R/sys"; \
			mount --bind /dev "$$R/dev"; \
			mount --bind /dev/pts "$$R/dev/pts"; \
			chroot "$$R" apt-get update -qq; \
			chroot "$$R" apt-get install -y -qq --no-install-recommends \
				linux-image-arm64 \
				initramfs-tools \
				systemd \
				systemd-sysv \
				systemd-resolved \
				openssh-server \
				e2fsprogs \
				jq curl wget git; \
			mkdir -p "$$R/etc/initramfs-tools"; \
			touch "$$R/etc/initramfs-tools/modules"; \
			for module in virtio_blk virtio_mmio virtio_pci ext4; do \
				grep -qx "$$module" "$$R/etc/initramfs-tools/modules" || \
					echo "$$module" >> "$$R/etc/initramfs-tools/modules"; \
			done; \
			chroot "$$R" systemctl enable systemd-networkd.service; \
			chroot "$$R" systemctl enable systemd-resolved.service; \
			mkdir -p "$$R/etc/systemd/network"; \
			printf "%s\n" \
				"[Match]" \
				"Name=en*" \
				"" \
				"[Network]" \
				"DHCP=yes" \
				> "$$R/etc/systemd/network/10-virtio.network"; \
			mkdir -p "$$R/var/lib/tailscale"; \
			touch "$$R/etc/fstab"; \
			if ! grep -q " /var/lib/tailscale " "$$R/etc/fstab"; then \
				printf "%s\n" \
					"LABEL=SPARKDATA /var/lib/tailscale ext4 defaults,nofail 0 2" \
					>> "$$R/etc/fstab"; \
			fi; \
			printf "%s\n" \
				"PermitRootLogin prohibit-password" \
				"PasswordAuthentication no" \
				"PubkeyAuthentication yes" \
				> "$$R/etc/ssh/sshd_config.d/99-wonderland.conf"; \
			chroot "$$R" update-initramfs -u -k all; \
			KERNEL_SOURCE=$$(find "$$R/boot" -maxdepth 1 -type f -name "vmlinuz-*" | sort -V | tail -1); \
			INITRD_SOURCE=$$(find "$$R/boot" -maxdepth 1 -type f -name "initrd.img-*" | sort -V | tail -1); \
			test -s "$$KERNEL_SOURCE"; \
			test -s "$$INITRD_SOURCE"; \
			MAGIC=$$(od -An -tx1 -N2 "$$KERNEL_SOURCE" | tr -d " \n"); \
			if [ "$$MAGIC" = "1f8b" ]; then \
				gzip -dc "$$KERNEL_SOURCE" > /build/vmlinuz; \
			else \
				cp "$$KERNEL_SOURCE" /build/vmlinuz; \
			fi; \
			ARM64_MAGIC=$$(od -An -tx1 -j56 -N4 /build/vmlinuz | tr -d " \n"); \
			if [ "$$ARM64_MAGIC" != "41524d64" ]; then \
				echo "FAIL: Kernel is not a validated uncompressed ARM64 Image"; \
				exit 1; \
			fi; \
			cp "$$INITRD_SOURCE" /build/initrd.img; \
			cleanup_mounts; \
			trap - EXIT; \
			truncate -s "$$ROOTFS_SIZE" /build/debian-bookworm-vm-rootfs.ext4; \
			mkfs.ext4 -F -L SPARKROOT -d "$$R" /build/debian-bookworm-vm-rootfs.ext4; \
			test -s /build/debian-bookworm-vm-rootfs.ext4; \
			test -s /build/vmlinuz; \
			test -s /build/initrd.img; \
			cd /build; \
			sha256sum debian-bookworm-vm-rootfs.ext4 vmlinuz initrd.img > checksums.sha256; \
			{ \
				echo "schema=wonderland.spark.build.v1"; \
				echo "base_image=$(BASE_IMAGE)"; \
				echo "architecture=arm64"; \
				echo "distribution=debian-bookworm"; \
				echo "rootfs_label=SPARKROOT"; \
				echo "data_label=SPARKDATA"; \
				echo "rootfs_size=$$ROOTFS_SIZE"; \
				echo "kernel_format=uncompressed-arm64-Image"; \
				echo "build_namespace=$(CONTAINER_NAMESPACE)"; \
			} > build-manifest.txt; \
			echo "PASS: Root filesystem packaged"; \
			echo "PASS: Uncompressed ARM64 kernel validated"; \
			echo "PASS: Initrd extracted"; \
			echo "PASS: Checksums generated"; \
		'; \
	if [ -d "$(BUILD_DIR)" ]; then \
		rmdir "$(BUILD_DIR)"; \
	fi; \
	mv "$$STAGE" "$(BUILD_DIR)"; \
	trap - EXIT HUP INT TERM; \
	echo "PASS: Candidate artifacts published: $(BUILD_DIR)"

# ============================================================================
# ARTIFACT VERIFICATION
# ============================================================================

vm-check-artifacts:
	@set -eu; \
	for f in "$(ROOTFS_PATH)" "$(KERNEL_PATH)" "$(INITRD_PATH)" \
	         "$(BUILD_STAMP)" "$(CHECKSUM_FILE)"; do \
		if [ ! -s "$$f" ]; then \
			echo "FAIL: Missing or empty artifact: $$f"; \
			exit 1; \
		fi; \
		echo "PASS: $$f"; \
	done; \
	cd "$(BUILD_DIR)"; \
	shasum -a 256 -c checksums.sha256; \
	MAGIC=$$(od -An -tx1 -j56 -N4 vmlinuz | tr -d ' \n'); \
	if [ "$$MAGIC" != "41524d64" ]; then \
		echo "FAIL: Kernel ARM64 Image magic mismatch"; \
		exit 1; \
	fi; \
	echo "PASS: Artifact checksum and kernel validation"

# ============================================================================
# PERSISTENT DATA DISK
#
# Creation is non-destructive. Existing data.ext4 is never overwritten.
# ============================================================================

$(DATA_DISK):
	@set -eu; \
	mkdir -p "$(BUILD_DIR)"; \
	if [ -e "$@" ]; then \
		echo "FAIL: Data disk already exists; refusing overwrite"; \
		exit 1; \
	fi; \
	TMP="$(BUILD_DIR)/.data.ext4.tmp.$$$$"; \
	trap 'rm -f "$$TMP"' EXIT HUP INT TERM; \
	echo "Creating persistent data disk..."; \
	$(NERDCTL) --namespace "$(CONTAINER_NAMESPACE)" run --rm \
		-v "$(BUILD_DIR):/build" \
		"$(BASE_IMAGE)" bash -euc '\
			apt-get update -qq; \
			apt-get install -y -qq --no-install-recommends e2fsprogs; \
			truncate -s "$(DATA_DISK_SIZE)" /build/.data.ext4.tmp.'"$$$$"'; \
			mkfs.ext4 -F -L SPARKDATA /build/.data.ext4.tmp.'"$$$$"'; \
		'; \
	mv "$$TMP" "$@"; \
	trap - EXIT HUP INT TERM; \
	echo "PASS: Persistent data disk created: $@"

# ============================================================================
# VM PROCESS IDENTITY
#
# A PID alone is never treated as proof of VM identity.
# ============================================================================

start-spark-debian: vm-artifacts $(DATA_DISK)
	@set -eu; \
	mkdir -p "$(LOG_DIR)"; \
	if [ -f "$(PID_FILE)" ]; then \
		PID=$$(cat "$(PID_FILE)"); \
		case "$$PID" in \
			""|*[!0-9]*) echo "FAIL: Invalid PID file; inspect manually"; exit 1 ;; \
		esac; \
		if kill -0 "$$PID" 2>/dev/null; then \
			CMD=$$(ps -p "$$PID" -o command= 2>/dev/null || true); \
			case "$$CMD" in \
				*vfkit*"$(ROOTFS_PATH)"*) \
					echo "FAIL: This Spark VM is already running (PID $$PID)"; \
					exit 1 ;; \
				*) \
					echo "FAIL: PID $$PID belongs to another process"; \
					echo "$$CMD"; \
					exit 1 ;; \
			esac; \
		else \
			echo "FAIL: Stale PID file exists: $(PID_FILE)"; \
			echo "Inspect and remove it manually after verification."; \
			exit 1; \
		fi; \
	fi; \
	echo "Launching Debian Spark VM..."; \
	nohup "$(VFKit)" \
		--cpus "$(CPUS)" \
		--memory "$(MEMORY_MB)" \
		--bootloader "linux,kernel=$(KERNEL_PATH),initrd=$(INITRD_PATH),cmdline=\"console=hvc0 root=LABEL=SPARKROOT rootfstype=ext4 rw panic=1\"" \
		--device "virtio-blk,path=$(ROOTFS_PATH)" \
		--device "virtio-blk,path=$(DATA_DISK)" \
		--device virtio-net,nat \
		--device "virtio-serial,logFilePath=$(SERIAL_LOG)" \
		--device virtio-rng \
		> "$(VFKit_LOG)" 2>&1 & \
	PID=$$!; \
	printf "%s\n" "$$PID" > "$(PID_FILE).tmp"; \
	mv "$(PID_FILE).tmp" "$(PID_FILE)"; \
	sleep 2; \
	if ! kill -0 "$$PID" 2>/dev/null; then \
		echo "FAIL: vfkit exited during startup"; \
		cat "$(VFKit_LOG)" || true; \
		rm -f "$(PID_FILE)"; \
		exit 1; \
	fi; \
	CMD=$$(ps -p "$$PID" -o command= 2>/dev/null || true); \
	case "$$CMD" in \
		*vfkit*"$(ROOTFS_PATH)"*) \
			echo "PASS: vfkit process started (PID $$PID)" ;; \
		*) \
			echo "FAIL: Could not verify vfkit process identity"; \
			echo "$$CMD"; \
			exit 1 ;; \
	esac

status-spark-debian:
	@set -eu; \
	if [ ! -f "$(PID_FILE)" ]; then \
		echo "STOPPED: No Spark PID file"; \
		exit 0; \
	fi; \
	PID=$$(cat "$(PID_FILE)"); \
	case "$$PID" in \
		""|*[!0-9]*) echo "FAIL: Invalid PID file"; exit 1 ;; \
	esac; \
	if ! kill -0 "$$PID" 2>/dev/null; then \
		echo "STALE PID FILE: $(PID_FILE)"; \
		exit 1; \
	fi; \
	CMD=$$(ps -p "$$PID" -o command= 2>/dev/null || true); \
	case "$$CMD" in \
		*vfkit*"$(ROOTFS_PATH)"*) \
			echo "PROCESS RUNNING: PID $$PID"; \
			echo "This confirms vfkit process existence, not guest readiness." ;; \
		*) \
			echo "FAIL: PID does not identify this Spark VM"; \
			echo "$$CMD"; \
			exit 1 ;; \
	esac; \
	echo "Serial log: $(SERIAL_LOG)"; \
	echo "vfkit log:  $(VFKit_LOG)"

stop-spark-debian:
	@set -eu; \
	if [ ! -f "$(PID_FILE)" ]; then \
		echo "STOPPED: No Spark PID file"; \
		exit 0; \
	fi; \
	PID=$$(cat "$(PID_FILE)"); \
	case "$$PID" in \
		""|*[!0-9]*) echo "FAIL: Invalid PID file"; exit 1 ;; \
	esac; \
	if ! kill -0 "$$PID" 2>/dev/null; then \
		echo "FAIL: Stale PID file; refusing to remove automatically"; \
		exit 1; \
	fi; \
	CMD=$$(ps -p "$$PID" -o command= 2>/dev/null || true); \
	case "$$CMD" in \
		*vfkit*"$(ROOTFS_PATH)"*) ;; \
		*) \
			echo "FAIL: PID identity mismatch; refusing to signal"; \
			echo "$$CMD"; \
			exit 1 ;; \
	esac; \
	echo "Sending SIGTERM to verified Spark vfkit PID $$PID"; \
	kill -TERM "$$PID"; \
	I=0; \
	while [ "$$I" -lt 15 ]; do \
		if ! kill -0 "$$PID" 2>/dev/null; then \
			break; \
		fi; \
		sleep 1; \
		I=$$((I + 1)); \
	done; \
	if kill -0 "$$PID" 2>/dev/null; then \
		CMD=$$(ps -p "$$PID" -o command= 2>/dev/null || true); \
		case "$$CMD" in \
			*vfkit*"$(ROOTFS_PATH)"*) kill -KILL "$$PID" ;; \
			*) echo "FAIL: Process identity changed; refusing SIGKILL"; exit 1 ;; \
		esac; \
	fi; \
	if kill -0 "$$PID" 2>/dev/null; then \
		echo "FAIL: Process remains alive"; \
		exit 1; \
	fi; \
	rm -f "$(PID_FILE)"; \
	echo "PASS: Verified Spark vfkit process stopped"

# ============================================================================
# SSH ACCESS
#
# No guest Tailscale provisioning, authorized key injection, or host-side
# guest SSH route has been implemented. Do not pretend SSH is ready.
# ============================================================================

launch-ssh:
	@echo "BLOCKED: Guest SSH access is not yet provisioned."
	@echo "Missing: authorized-key provisioning, guest network discovery,"
	@echo "and a verified host-to-guest SSH transport."
	@echo "The target will not start the VM or claim SSH readiness."
	@exit 2

# ============================================================================
# SAFE CLEANUP
#
# Requires explicit candidate confirmation.
# Does not delete logs.
# Does not delete a running VM's artifacts.
# ============================================================================

clean:
	@set -eu; \
	if [ "$(CONFIRM_CLEAN)" != "$(BUILD_CANDIDATE)" ]; then \
		echo "FAIL: Explicit confirmation required."; \
		echo "Run: make clean CONFIRM_CLEAN=$(BUILD_CANDIDATE)"; \
		exit 1; \
	fi; \
	case "$(BUILD_CANDIDATE)" in \
		""|.|..|*/*) echo "FAIL: Invalid candidate name"; exit 1 ;; \
	esac; \
	if [ -L "$(BUILD_DIR)" ]; then \
		echo "FAIL: Candidate path is a symlink"; \
		exit 1; \
	fi; \
	if [ -f "$(PID_FILE)" ]; then \
		echo "FAIL: PID file exists; verify VM is stopped first"; \
		exit 1; \
	fi; \
	if [ -d "$(BUILD_DIR)" ]; then \
		rm -rf "$(BUILD_DIR)"; \
		echo "PASS: Candidate directory removed"; \
	else \
		echo "PASS: Candidate directory does not exist"; \
	fi; \
	echo "Logs preserved: $(LOG_DIR)"

# ============================================================================
# TAYLORZONE ZERO-TRUST STORAGE & MESH PIPELINE
#
# This target performs real deployment operations.
# It is deliberately separate from the default target.
# ============================================================================

taylorzone-deploy:
	@set -eu; \
	for f in \
		scripts/manage_taylorzone_vault.zsh \
		scripts/configure_taylorzone_syncthing.zsh \
		scripts/deploy_tailscale_acls.zsh \
		scripts/audit_taylorzone.zsh; do \
		test -f "$(ROOT_DIR)/$$f" || { echo "FAIL: Missing $$f"; exit 1; }; \
	done; \
	test -f "$(ROOT_DIR)/taylorzone/policy.hujson" || { \
		echo "FAIL: TaylorZone policy file missing"; exit 1; \
	}; \
	echo "[1/4] Mounting APFS vault..."; \
	cd "$(ROOT_DIR)" && zsh scripts/manage_taylorzone_vault.zsh "" mount; \
	echo "[2/4] Configuring Syncthing..."; \
	cd "$(ROOT_DIR)" && zsh scripts/configure_taylorzone_syncthing.zsh; \
	echo "[3/4] Deploying Tailscale ACL policy..."; \
	cd "$(ROOT_DIR)" && zsh scripts/deploy_tailscale_acls.zsh "$(ROOT_DIR)/taylorzone/policy.hujson"; \
	echo "[4/4] Running infrastructure audit..."; \
	cd "$(ROOT_DIR)" && zsh scripts/audit_taylorzone.zsh; \
	echo "PASS: TaylorZone deployment and audit completed"

# ============================================================================
# PYTHON DEVELOPMENT ENVIRONMENT
# ============================================================================

setup-venv:
	@set -eu; \
	cd "$(ROOT_DIR)"; \
	if [ ! -d .venv ]; then \
		python3 -m venv .venv; \
	fi; \
	.venv/bin/python -m pip install --upgrade pip; \
	.venv/bin/python -m pip install -e '.[dev]'; \
	echo "PASS: Wonderland Python development environment configured"

# ============================================================================
# WONDERLAND CONTROL PLANE
# ============================================================================

control-test: setup-venv
	@cd "$(ROOT_DIR)" && \
	$(PYTEST) \
		--cov=wonderland.daemons.control \
		--cov=wonderland.core.adapters \
		--cov-report=term-missing \
		--cov-fail-under=100 \
		tests/test_control_daemon.py -v

# The present service has lifecycle-handler methods only.
# It lacks a concrete ControlExecutor, event loop, and executable entrypoint.
control-daemon-start:
	@echo "BLOCKED: ControlDaemonService is not an executable daemon."
	@echo "A concrete ControlExecutor, runtime loop, and CLI entrypoint are required."
	@echo "No process was started."
	@exit 2

control-daemon-stop:
	@echo "BLOCKED: No verified Control Daemon process lifecycle exists."
	@echo "No process was signaled."
	@exit 2

control-audit-tail:
	@set -eu; \
	if [ -f "$(CONTROL_AUDIT_LOG)" ]; then \
		tail -n 50 "$(CONTROL_AUDIT_LOG)"; \
	else \
		echo "No Crystal audit log found: $(CONTROL_AUDIT_LOG)"; \
	fi

# ============================================================================
# BENCHMARK
#
# No benchmark implementation was present in the supplied Makefile.
# Fail explicitly rather than reporting a false successful no-op.
# ============================================================================

benchmark:
	@echo "BLOCKED: No benchmark implementation is defined."
	@echo "Add a verified benchmark command before enabling this target."
	@exit 2

# ============================================================================
# END
# ============================================================================
