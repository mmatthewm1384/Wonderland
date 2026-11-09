SHELL := /bin/zsh
WORKSPACE_ROOT ?= /Users/Wonderland/wonderland
ASSET_DIR ?= $(WORKSPACE_ROOT)/assets
ROOTFS ?= $(ASSET_DIR)/rootfs.img
SENTINEL ?= $(ASSET_DIR)/.rootfs.built
SSH_PUBKEY ?= $(HOME)/.ssh/id_ed25519.pub
LOG_FILE ?= /tmp/vfkit_serial.log
VM_NAME = spark-ephemeral
CPUS = 2
MEMORY = 2048
KERNEL = $(ASSET_DIR)/Image
INITRD = $(ASSET_DIR)/initramfs-virt.img
PODMAN_URL ?= unix:///run/user/501/podman/podman.sock

.PHONY: all up down clean verify verify-assets mock-assets check-podman ssh test test-golden test-manifest test-update

all: up

check-podman:
	@if ! podman machine inspect NLNights >/dev/null 2>&1; then \
		echo "[+] Podman machine 'NLNights' not found. Initializing..."; \
		podman machine init NLNights; \
	fi
	@if ! podman machine inspect NLNights --format '{{.State}}' 2>/dev/null | grep -q "running"; then \
		echo "[+] Starting Podman machine NLNights..."; \
		podman machine start NLNights; \
	else \
		echo "[+] Podman machine NLNights is already running."; \
	fi

verify-assets:
	@echo "[+] Verifying Spark assets..."
	@if [ ! -f "$(KERNEL)" ]; then echo "[!] Error: Kernel '$(KERNEL)' missing."; exit 1; fi
	@if [ ! -f "$(INITRD)" ]; then echo "[!] Error: Initrd '$(INITRD)' missing."; exit 1; fi
	@if [ ! -f "$(ROOTFS)" ]; then echo "[!] Error: RootFS '$(ROOTFS)' missing. Run make clean && make up first."; exit 1; fi
	@echo "  [OK] Kernel present"
	@echo "  [OK] Initrd present"
	@echo "  [OK] RootFS present"

mock-assets:
	@echo "[+] Generating mock kernel and initrd stubs for CI..."
	@mkdir -p $(ASSET_DIR)
	@touch $(KERNEL)
	@touch $(INITRD)
	@echo "[+] Generating mock serial boot log..."
	@echo "[    0.000000] Linux version 6.x.x-mock (wonderland) #1 SMP PREEMPT" > /tmp/vfkit_serial.log
	@echo "[    0.500000] systemd[1]: Reached target Multi-User System." >> /tmp/vfkit_serial.log
	@echo "[    1.000000] Spark ephemeral guest initialized successfully." >> /tmp/vfkit_serial.log

up: $(ROOTFS) verify-assets check-podman
	@echo "[+] Launching Spark micro-VM ($(VM_NAME))..."
	@rm -f "$(LOG_FILE)"
	vfkit \
		--cpus $(CPUS) \
		--memory $(MEMORY) \
		--kernel "$(KERNEL)" \
		--initrd "$(INITRD)" \
		--kernel-cmdline "console=ttyS0 console=hvc0 root=/dev/vda rw systemd.unit=multi-user.target panic=1" \
		--device virtio-blk,path="$(ROOTFS)" \
		--device virtio-net,nat \
		--device virtio-fs,sharedDir="$(ASSET_DIR)",mountTag="workspace-share" \
		--device virtio-serial,stdio | tee "$(LOG_FILE)"

ssh:
	@echo "[+] Resolving Spark micro-VM IP address from macOS DHCP leases..."
	@VM_IP=$$(plutil -p /var/db/dhcpd_leases 2>/dev/null | grep -B 2 -A 10 "vfkit" | grep "ip_address" | awk -F'"' '{print $$4}' | tail -n 1); \
	if [ -z "$$VM_IP" ]; then \
		echo "[!] DHCP lease not found. Inspecting recent serial log entries..."; \
		tail -n 30 $(LOG_FILE); \
		exit 1; \
	fi; \
	echo "[+] Connecting to root@$$VM_IP via SSH..."; \
	ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $(shell dirname $(SSH_PUBKEY))/id_ed25519 root@$$VM_IP

$(ROOTFS): $(SENTINEL)

$(SENTINEL): check-podman
	@echo "[+] Waiting for Podman VM socket..."
	@for i in {1..15}; do \
		podman --url $(PODMAN_URL) info >/dev/null 2>&1 && break; \
		sleep 1; \
	done
	@CURRENT_IMAGE_ID=$$(podman --url $(PODMAN_URL) inspect --format='{{.Id}}' localhost/spark-rootfs:local 2>/dev/null || echo "none"); \
	RECORDED_IMAGE_ID=$$(cat $@ 2>/dev/null || echo "none"); \
	if [ "$$CURRENT_IMAGE_ID" = "$$RECORDED_IMAGE_ID" ] && [ -f "$(ROOTFS)" ]; then \
		echo "[+] RootFS and container image are up to date. Skipping rebuild."; \
	else \
		echo "[+] Rebuilding rootfs.img (missing image or updated container)..."; \
		rm -f $(ROOTFS); \
		dd if=/dev/zero of=$(ROOTFS) bs=1M count=2048 status=progress; \
		echo "[+] Exporting container rootfs to staging..."; \
		podman --url $(PODMAN_URL) rm -f temp-spark-ctr >/dev/null 2>&1 || true; \
		podman --url $(PODMAN_URL) create --name temp-spark-ctr localhost/spark-rootfs:local; \
		rm -rf /tmp/spark-rootfs-staging; \
		mkdir -p /tmp/spark-rootfs-staging; \
		podman --url $(PODMAN_URL) export temp-spark-ctr | tar -x -C /tmp/spark-rootfs-staging; \
		podman --url $(PODMAN_URL) rm temp-spark-ctr; \
		mkdir -p /tmp/spark-rootfs-staging/root/.ssh; \
		chmod 700 /tmp/spark-rootfs-staging/root/.ssh; \
		cp $(SSH_PUBKEY) /tmp/spark-rootfs-staging/root/.ssh/authorized_keys; \
		chmod 600 /tmp/spark-rootfs-staging/root/.ssh/authorized_keys; \
		mkfs.ext4 -L "SPARKROOT" -d /tmp/spark-rootfs-staging $(ROOTFS); \
		rm -rf /tmp/spark-rootfs-staging; \
		echo "$$CURRENT_IMAGE_ID" > $@; \
		echo "[PASS] RootFS built and sentinel updated successfully."; \
	fi

test: mock-assets test-golden test-manifest

test-golden:
	@echo "[+] Running golden file regression tests..."
	python3 $(WORKSPACE_ROOT)/tests/test_golden.py

test-manifest:
	@echo "[+] Running rootfs manifest golden test..."
	python3 $(WORKSPACE_ROOT)/tests/test_manifest.py

test-update:
	@echo "[+] Updating all golden reference files..."
	python3 $(WORKSPACE_ROOT)/tests/test_golden.py --update
	python3 $(WORKSPACE_ROOT)/tests/test_manifest.py --update
	@echo "[PASS] All golden references successfully updated."

down:
	@echo "[+] Terminating running vfkit instances..."
	@pkill -f vfkit || true

clean: down
	@echo "[+] Purging ephemeral state and forensic footprints..."
	@rm -f $(ROOTFS) $(SENTINEL) $(LOG_FILE)
	@echo "[+] Teardown complete. Volatile RAM and disk traces scrubbed."
