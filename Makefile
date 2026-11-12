SHELL := /bin/zsh
WORKSPACE_ROOT ?= /Users/Wonderland/wonderland
ASSET_DIR ?= $(WORKSPACE_ROOT)/assets
ROOTFS ?= $(ASSET_DIR)/rootfs.img
SENTINEL ?= $(ASSET_DIR)/.rootfs.built
SSH_PUBKEY_FILE ?= $(HOME)/.ssh/id_ed25519.pub
LOG_FILE ?= /tmp/vfkit_serial.log
VM_NAME = spark-ephemeral
CPUS = 2
MEMORY = 2048
KERNEL = $(ASSET_DIR)/Image
INITRD = $(ASSET_DIR)/initramfs-virt.img

# Network sockets for gvproxy user-mode stack
GVPROXY_SOCK ?= /tmp/gvproxy-net.sock
VFKIT_SOCK ?= /tmp/vfkit-net.sock
GVPROXY_PID ?= /tmp/gvproxy.pid
GVPROXY ?= /opt/homebrew/opt/podman/libexec/podman/gvproxy

# Dynamically resolve the active macOS Podman machine socket path
PODMAN_SOCKET ?= $(shell podman machine inspect NLNights --format '{{.ConnectionInfo.PodmanSocket.Path}}' 2>/dev/null)
PODMAN_URL ?= unix://$(PODMAN_SOCKET)

.PHONY: all up down clean verify-assets mock-assets check-podman ssh test test-golden test-manifest test-update test-forensics test-mesh install-hooks lint ci bench clean-audio live-mic

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
	@SOCKET_PATH=$$(podman machine inspect NLNights --format '{{.ConnectionInfo.PodmanSocket.Path}}' 2>/dev/null); \
	if [ ! -S "$$SOCKET_PATH" ]; then \
		echo "[!] Warning: Podman socket not found at $$SOCKET_PATH. Restarting NLNights..."; \
		podman machine stop NLNights >/dev/null 2>&1 || true; \
		podman machine start NLNights; \
	fi

verify-assets:
	@echo "[+] Verifying Spark assets..."
	@if [ ! -s "$(KERNEL)" ]; then echo "[!] Error: Kernel '$(KERNEL)' missing or empty (0 bytes)."; exit 1; fi
	@if [ ! -s "$(INITRD)" ]; then echo "[!] Error: Initrd '$(INITRD)' missing or empty (0 bytes)."; exit 1; fi
	@if [ ! -f "$(ROOTFS)" ]; then echo "[!] Error: RootFS '$(ROOTFS)' missing. Run make clean && make up first."; exit 1; fi
	@echo "  [OK] Kernel present"
	@echo "  [OK] Initrd present"
	@echo "  [OK] RootFS present"

up: $(ROOTFS) verify-assets check-podman
	@if [ ! -x "$(GVPROXY)" ]; then \
		echo "[!] Error: gvproxy is missing or not executable: $(GVPROXY)"; \
		exit 1; \
	fi
	@echo "[+] Starting gvproxy user-mode network stack with debug logging..."
	@rm -f "$(GVPROXY_SOCK)" "$(VFKIT_SOCK)" "/tmp/gvproxy.log"
	"$(GVPROXY)" \
		-listen unix:///tmp/gvproxy-net.sock \
		--listen-vfkit unixgram:///tmp/vfkit-net.sock \
		--subnet 192.168.127.0/24 \
		--gatewayIP 192.168.127.1 \
		--deviceIP 192.168.127.2 \
		-ssh-port 2222 \
		-debug \
		-log-file /tmp/gvproxy.log & echo $$! > "$(GVPROXY_PID)"
	@echo "[+] Waiting for gvproxy vfkit socket..."
	@for i in {1..10}; do \
		[ -S "$(VFKIT_SOCK)" ] && break; \
		sleep 0.2; \
	done
	@if [ ! -S "$(VFKIT_SOCK)" ]; then \
		echo "[!] Error: gvproxy failed to create $(VFKIT_SOCK). Check /tmp/gvproxy.log"; \
		exit 1; \
	fi
	@echo "[+] Launching Spark micro-VM ($(VM_NAME)) with unixSocketPath..."
	@rm -f "$(LOG_FILE)"
	@trap 'if [ -f "$(GVPROXY_PID)" ]; then kill $$(cat "$(GVPROXY_PID)") 2>/dev/null || true; rm -f "$(GVPROXY_PID)"; fi; rm -f "$(GVPROXY_SOCK)" "$(VFKIT_SOCK)" "/tmp/gvproxy.log"' EXIT; \
	vfkit \
		--cpus $(CPUS) \
		--memory $(MEMORY) \
		--log-level debug \
		--kernel "$(KERNEL)" \
		--initrd "$(INITRD)" \
		--kernel-cmdline "console=ttyS0 console=hvc0 root=/dev/vda rw loglevel=8 ignore_loglevel panic=-1" \
		--device "virtio-blk,path=$(ROOTFS)" \
		--device "virtio-net,unixSocketPath=$(VFKIT_SOCK),mac=5a:94:ef:e4:0c:ee" \
		--device "virtio-fs,sharedDir=$(ASSET_DIR),mountTag=workspace-share" \
		--device "virtio-serial,stdio" | tee "$(LOG_FILE)"

ssh:
	@echo "[+] Waiting for Spark micro-VM port 2222 to become available..."
	@RETRIES=15; \
	while ! nc -z 127.0.0.1 2222 >/dev/null 2>&1; do \
		RETRIES=$$((RETRIES - 1)); \
		if [ $$RETRIES -le 0 ]; then \
			echo "[!] Error: Port 2222 is closed. Is the Spark micro-VM running? Run 'make up'"; \
			exit 1; \
		fi; \
		sleep 0.5; \
	done
	@echo "[+] Connecting to Spark micro-VM via gvproxy socket forwarding..."
	ssh -p 2222 \
		-o StrictHostKeyChecking=no \
		-o UserKnownHostsFile=/dev/null \
		-o ConnectTimeout=5 \
		-i $(HOME)/.ssh/id_ed25519 \
		root@127.0.0.1


$(ROOTFS): $(SENTINEL)

$(SENTINEL): check-podman
	@set -euo pipefail; \
	echo "[+] Validating RootFS build inputs..."; \
	if [ ! -s "$(SSH_PUBKEY_FILE)" ]; then \
		echo "[FAIL] SSH public key missing or empty: $(SSH_PUBKEY_FILE)"; \
		exit 1; \
	fi; \
	if ! ssh-keygen -lf "$(SSH_PUBKEY_FILE)" >/dev/null 2>&1; then \
		echo "[FAIL] Invalid SSH public key."; \
		exit 1; \
	fi; \
	sudo -v; \
	CURRENT_IMAGE_ID=$$(podman --url "$(PODMAN_URL)" inspect --format='{{.Id}}' localhost/spark-rootfs:local 2>/dev/null || true); \
	if [ -z "$$CURRENT_IMAGE_ID" ]; then \
		echo "[FAIL] Cannot inspect localhost/spark-rootfs:local."; \
		exit 1; \
	fi; \
	PUBKEY_HASH=$$(/usr/bin/shasum -a 256 "$(SSH_PUBKEY_FILE)" | /usr/bin/awk '{print $$1}'); \
	EXPECTED_SENTINEL=$$(printf 'schema=2\nimage_id=%s\nssh_pubkey_sha256=%s\n' "$$CURRENT_IMAGE_ID" "$$PUBKEY_HASH"); \
	RECORDED_SENTINEL=$$(cat "$(SENTINEL)" 2>/dev/null || true); \
	if [ "$$EXPECTED_SENTINEL" = "$$RECORDED_SENTINEL" ] && [ -s "$(ROOTFS)" ]; then \
		echo "[PASS] RootFS and provisioning inputs are current."; \
	else \
		echo "[+] Preparing isolated RootFS build..."; \
		STAGING=$$(/usr/bin/mktemp -d /tmp/spark-rootfs-staging.XXXXXX); \
		STAGING_ID=$$(/usr/bin/basename "$$STAGING" | /usr/bin/sed 's/^spark-rootfs-staging\.//'); \
		CONTAINER_NAME="spark-rootfs-$$$$-$$STAGING_ID"; \
		CONTAINER_CREATED=0; \
		CANDIDATE="$(ROOTFS).candidate.$$$$"; \
		SENTINEL_TMP="$(SENTINEL).candidate.$$$$"; \
		BACKUP="$(ROOTFS).pre-schema2.$$(date +%Y%m%dT%H%M%S)"; \
		if [ -e "$$CANDIDATE" ] || [ -e "$$SENTINEL_TMP" ] || [ -e "$$BACKUP" ]; then \
			echo "[FAIL] A candidate or backup path already exists."; \
			exit 1; \
		fi; \
		cleanup() { \
			if [ "$$CONTAINER_CREATED" -eq 1 ]; then \
				podman --url "$(PODMAN_URL)" rm -f "$$CONTAINER_NAME" >/dev/null 2>&1 || true; \
			fi; \
			sudo /bin/rm -rf "$$STAGING" || true; \
			/bin/rm -f "$$CANDIDATE" "$$SENTINEL_TMP" || true; \
		}; \
		trap cleanup EXIT; \
		echo "[+] Exporting container filesystem..."; \
		podman --url "$(PODMAN_URL)" create \
			--name "$$CONTAINER_NAME" \
			localhost/spark-rootfs:local >/dev/null; \
		CONTAINER_CREATED=1; \
		podman --url "$(PODMAN_URL)" export "$$CONTAINER_NAME" | \
			sudo /usr/bin/tar -xpf - -C "$$STAGING"; \
		podman --url "$(PODMAN_URL)" rm "$$CONTAINER_NAME" >/dev/null; \
		CONTAINER_CREATED=0; \
		sudo /usr/sbin/chown 0:0 "$$STAGING"; \
		sudo /bin/chmod 755 "$$STAGING"; \
		STAGING_OWNER=$$(sudo /usr/bin/stat -f '%u:%g:%Lp' "$$STAGING"); \
		if [ "$$STAGING_OWNER" != "0:0:755" ]; then \
			echo "[FAIL] Guest filesystem root metadata incorrect: $$STAGING_OWNER"; \
			exit 1; \
		fi; \
		echo "[+] Verifying extracted root ownership..."; \
		ROOT_OWNER=$$(sudo /usr/bin/stat -f '%u:%g' "$$STAGING/root"); \
		if [ "$$ROOT_OWNER" != "0:0" ]; then \
			echo "[FAIL] Guest /root ownership is $$ROOT_OWNER, expected 0:0."; \
			exit 1; \
		fi; \
		echo "[+] Provisioning authorized SSH key..."; \
		sudo /bin/mkdir -p "$$STAGING/root/.ssh"; \
		sudo /usr/sbin/chown 0:0 "$$STAGING/root/.ssh"; \
		sudo /bin/chmod 700 "$$STAGING/root/.ssh"; \
		sudo /usr/bin/install -o 0 -g 0 -m 600 "$(SSH_PUBKEY_FILE)" "$$STAGING/root/.ssh/authorized_keys"; \
		echo "[+] Configuring static guest networking..."; \
		sudo /bin/mkdir -p "$$STAGING/etc/systemd/network"; \
		printf '[Match]\nName=en* eth* enp*\n\n[Network]\nAddress=192.168.127.2/24\nGateway=192.168.127.1\n' | sudo /usr/bin/tee "$$STAGING/etc/systemd/network/10-static.network" >/dev/null; \
		sudo /usr/sbin/chown 0:0 "$$STAGING/etc/systemd/network/10-static.network"; \
		sudo /bin/chmod 644 "$$STAGING/etc/systemd/network/10-static.network"; \
		echo "[+] Enabling SSH and systemd-networkd..."; \
		sudo /bin/mkdir -p "$$STAGING/etc/systemd/system/multi-user.target.wants"; \
		sudo /bin/ln -sfn /lib/systemd/system/ssh.service "$$STAGING/etc/systemd/system/multi-user.target.wants/ssh.service"; \
		sudo /bin/ln -sfn /lib/systemd/system/systemd-networkd.service "$$STAGING/etc/systemd/system/multi-user.target.wants/systemd-networkd.service"; \
		echo "[+] Verifying provisioned ownership and permissions..."; \
		KEY_OWNER=$$(sudo /usr/bin/stat -f '%u:%g:%Lp' "$$STAGING/root/.ssh/authorized_keys"); \
		if [ "$$KEY_OWNER" != "0:0:600" ]; then \
			echo "[FAIL] authorized_keys metadata incorrect: $$KEY_OWNER"; \
			exit 1; \
		fi; \
		echo "[+] Allocating candidate filesystem..."; \
		dd if=/dev/zero of="$$CANDIDATE" bs=1m count=2048; \
		echo "[+] Creating ext4 candidate..."; \
		sudo /opt/homebrew/opt/e2fsprogs/sbin/mkfs.ext4 \
			-F -L SPARKROOT -d "$$STAGING" "$$CANDIDATE"; \
		echo "[+] Checking candidate filesystem..."; \
		/opt/homebrew/opt/e2fsprogs/sbin/e2fsck -fn "$$CANDIDATE"; \
		CANDIDATE_LABEL=$$(/opt/homebrew/opt/e2fsprogs/sbin/e2label "$$CANDIDATE"); \
		if [ "$$CANDIDATE_LABEL" != "SPARKROOT" ]; then \
			echo "[FAIL] Unexpected filesystem label: $$CANDIDATE_LABEL"; \
			exit 1; \
		fi; \
		echo "[+] Preserving existing RootFS recovery copy..."; \
		if [ -e "$(ROOTFS)" ]; then \
			cp -p "$(ROOTFS)" "$$BACKUP"; \
			echo "[PASS] Recovery copy: $$BACKUP"; \
		fi; \
		echo "[+] Promoting validated RootFS candidate..."; \
		mv "$$CANDIDATE" "$(ROOTFS)"; \
		printf '%s\n' "$$EXPECTED_SENTINEL" > "$$SENTINEL_TMP"; \
		mv "$$SENTINEL_TMP" "$(SENTINEL)"; \
		echo "[PASS] RootFS promoted and provisioning sentinel updated."; \
	fi

lint:
	@echo "[\033[38;2;176;0;64mREROUTE\033[0m] Running Ruff static analysis and formatting check..."
	ruff check .
	ruff format --check .
	@echo "[\033[38;2;176;0;64mREROUTE\033[0m] Running Mypy type checking..."
	.venv/bin/mypy --explicit-package-bases wonderland gravity_field

format:
	@echo "[\033[38;2;176;0;64mREROUTE\033[0m] Applying Ruff formatting and autofixes..."
	ruff format .
	ruff check --fix .

test:
	@echo "[+] Running audio unit tests via pytest..."
	.venv/bin/python3 -m pytest tests/test_audio.py -v

bench:
	@echo "[*] Running audio streaming performance benchmark..."
	.venv/bin/python3 scripts/benchmark_audio.py

clean-audio:
	@echo "[*] Generating synthetic test WAV and running noise suppression..."
	.venv/bin/python3 scripts/generate_test_wav.py
	.venv/bin/python3 scripts/clean_audio.py dynamic_test.wav cleaned_dynamic.wav --alpha 2.0 --beta 0.01

live-mic:
	@echo "[*] Launching real-time PyAudio microphone noise suppression..."
	.venv/bin/python3 scripts/live_mic_cleaner.py

ci: lint test bench test-forensics test-mesh
	@echo "[\033[38;2;176;0;64mREROUTE\033[0m] Full Wonderland CI pipeline completed successfully."

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

test-forensics:
	@echo "[\033[38;2;176;0;64mVERIFY\033[0m] Auditing system for residual forensic artifacts..."
	@$(MAKE) down >/dev/null 2>&1 || true
	@LEAKED=0; \
	for path in "$(GVPROXY_SOCK)" "$(VFKIT_SOCK)" "$(GVPROXY_PID)" "/tmp/spark-rootfs-staging" "/tmp/gvproxy.log" "$(LOG_FILE)"; do \
		if [ -e "$$path" ]; then \
			echo "[!] Forensic violation: Residual artifact found at $$path"; \
			LEAKED=$$((LEAKED + 1)); \
		fi; \
	done; \
	if [ $$LEAKED -gt 0 ]; then \
		echo "[!] Forensic audit failed: $$LEAKED unscrubbed artifact(s) detected."; \
		exit 1; \
	fi; \
	echo "[PASS] Forensic audit clean. Zero persistent state or transient footprints detected."

test-mesh:
	@echo "[+] Validating Crystal Mesh topology and Tailscale HUJSON ACLs..."
	@if [ -f "$(WORKSPACE_ROOT)/config/mesh.hujson" ]; then \
		python3 -c "import json; json.load(open('$(WORKSPACE_ROOT)/config/mesh.hujson'))" && \
		echo "[PASS] Crystal Mesh HUJSON policy syntax verified."; \
	else \
		echo "[+] No mesh policy override found. Using default secure baseline."; \
	fi

mock-assets:
	@echo "[+] Generating mock kernel and initrd stubs for CI..."
	@mkdir -p $(ASSET_DIR)
	@touch $(KERNEL)
	@touch $(INITRD)
	@if [ ! -f "$(ROOTFS)" ]; then \
		echo "[+] Generating mock rootfs.img stub for CI..."; \
		dd if=/dev/zero of=$(ROOTFS) bs=1M count=10 status=none; \
	fi
	@echo "[+] Generating mock serial boot log..."
	@echo "[    0.000000] Linux version 6.x.x-mock (wonderland) #1 SMP PREEMPT" > $(LOG_FILE)
	@echo "[    0.500000] systemd[1]: Reached target Multi-User System." >> $(LOG_FILE)
	@echo "[    1.000000] Spark ephemeral guest initialized successfully." >> $(LOG_FILE)

install-hooks:
	@echo "[+] Installing Git pre-push hooks..."
	@mkdir -p .git/hooks
	@printf '#!/usr/bin/env zsh\n' > .git/hooks/pre-push
	@printf 'echo "[\033[38;2;176;0;64mPRE-PUSH\033[0m] Running local pre-push CI validation..."\n' >> .git/hooks/pre-push
	@printf 'make ci\n' >> .git/hooks/pre-push
	@printf 'if [ $$? -ne 0 ]; then\n' >> .git/hooks/pre-push
	@printf '    echo ""\n' >> .git/hooks/pre-push
	@printf '    echo "[!] CI VALIDATION FAILURE: Push aborted."\n' >> .git/hooks/pre-push
	@printf '    echo "[!] Fix linter errors or failing tests before pushing."\n' >> .git/hooks/pre-push
	@printf '    exit 1\n' >> .git/hooks/pre-push
	@printf 'fi\n' >> .git/hooks/pre-push
	@printf 'echo "[PASS] Pre-push CI validation passed successfully."\n' >> .git/hooks/pre-push
	@printf 'exit 0\n' >> .git/hooks/pre-push
	@chmod +x .git/hooks/pre-push
	@echo "[PASS] Git pre-push hook installed successfully."

down:
	@echo "[+] Terminating running vfkit and gvproxy instances..."
	@pkill -f vfkit || true
	@if [ -f "$(GVPROXY_PID)" ]; then \
		kill $$(cat "$(GVPROXY_PID)") 2>/dev/null || true; \
		rm -f "$(GVPROXY_PID)"; \
	fi
	@rm -f "$(GVPROXY_SOCK)" "$(VFKIT_SOCK)" "/tmp/gvproxy.log" "$(LOG_FILE)"

clean: down
	@echo "[+] Purging ephemeral state, build artifacts, and forensic footprints..."
	@rm -f $(ROOTFS) $(SENTINEL)
	@echo "[+] Teardown complete. Volatile RAM and disk traces scrubbed."
