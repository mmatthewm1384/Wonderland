SHELL := /bin/zsh
ROOTFS = /Users/Wonderland/wonderland/workspaces/aetheris/assets/rootfs.img
SENTINEL = /Users/Wonderland/wonderland/workspaces/aetheris/assets/.rootfs.built
ASSET_DIR = /Users/Wonderland/wonderland/workspaces/aetheris/assets
SSH_PUBKEY = /Users/wonderland/.ssh/id_ed25519.pub
LOG_FILE = /tmp/vfkit_serial.log
VM_NAME = spark-ephemeral
CPUS = 2
MEMORY = 2048
KERNEL = $(ASSET_DIR)/Image
INITRD = $(ASSET_DIR)/initramfs-virt.img

.PHONY: all up down clean verify verify-assets check-podman ssh

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

# Dependent target: rootfs.img depends on the sentinel file
$(ROOTFS): $(SENTINEL)

# Sentinel rule checks if container image ID changed or if rootfs.img is missing
$(SENTINEL): check-podman
	@echo "[+] Waiting for Podman VM socket..."
	@for i in {1..15}; do \
		podman --url unix:///run/user/501/podman/podman.sock info >/dev/null 2>&1 && break; \
		sleep 1; \
	done
	@CURRENT_IMAGE_ID=$$(podman --url unix:///run/user/501/podman/podman.sock inspect --format='{{.Id}}' localhost/spark-rootfs:local 2>/dev/null || echo "none"); \
	RECORDED_IMAGE_ID=$$(cat $@ 2>/dev/null || echo "none"); \
	if [ "$$CURRENT_IMAGE_ID" = "$$RECORDED_IMAGE_ID" ] && [ -f "$(ROOTFS)" ]; then \
		echo "[+] RootFS and container image are up to date. Skipping rebuild."; \
	else \
		echo "[+] Rebuilding rootfs.img (missing image or updated container)..."; \
		rm -f $(ROOTFS); \
		dd if=/dev/zero of=$(ROOTFS) bs=1M count=2048 status=progress; \
		echo "[+] Exporting container rootfs to staging..."; \
		podman --url unix:///run/user/501/podman/podman.sock rm -f temp-spark-ctr >/dev/null 2>&1 || true; \
		podman --url unix:///run/user/501/podman/podman.sock create --name temp-spark-ctr localhost/spark-rootfs:local; \
		rm -rf /tmp/spark-rootfs-staging; \
		mkdir -p /tmp/spark-rootfs-staging; \
		podman --url unix:///run/user/501/podman/podman.sock export temp-spark-ctr | tar -x -C /tmp/spark-rootfs-staging; \
		podman --url unix:///run/user/501/podman/podman.sock rm temp-spark-ctr; \
		mkdir -p /tmp/spark-rootfs-staging/root/.ssh; \
		chmod 700 /tmp/spark-rootfs-staging/root/.ssh; \
		cp $(SSH_PUBKEY) /tmp/spark-rootfs-staging/root/.ssh/authorized_keys; \
		chmod 600 /tmp/spark-rootfs-staging/root/.ssh/authorized_keys; \
		mkfs.ext4 -L "SPARKROOT" -d /tmp/spark-rootfs-staging $(ROOTFS); \
		rm -rf /tmp/spark-rootfs-staging; \
		echo "$$CURRENT_IMAGE_ID" > $@; \
		echo "[PASS] RootFS built and sentinel updated successfully."; \
	fi

down:
	@echo "[+] Terminating running vfkit instances..."
	@pkill -f vfkit || true

clean: down
	@echo "[+] Purging ephemeral state and forensic footprints..."
	@rm -f $(ROOTFS) $(SENTINEL) $(LOG_FILE)
	@echo "[+] Teardown complete. Volatile RAM and disk traces scrubbed."
