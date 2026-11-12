import os
import shutil
import subprocess

assets_dir = "/Users/wonderland/Developer/projects/aetheris/assets"
vmlinuz_path = os.path.join(assets_dir, "vmlinuz")
raw_disk = os.path.join(assets_dir, "boot_disk.img")

print("[+] Building proper GPT EFI boot disk...")

# 1. Create a 128MB raw disk image
disk_size = 128 * 1024 * 1024
with open(raw_disk, "wb") as f:
    f.write(b"\0" * disk_size)

# 2. Attach as a disk device using hdiutil
attach_out = subprocess.run(
    ["hdiutil", "attach", "-nomount", raw_disk], capture_output=True, text=True, check=True
)
device_node = attach_out.stdout.strip().split()[0]
print(f"[+] Attached raw image to {device_node}")

try:
    # 3. Partition with GPT and create an EFI System Partition (ESP)
    subprocess.run(["sudo", "gpt", "create", "-f", device_node], check=True)
    # Add EFI partition (size ~64MB, type C12A7328-F81F-11D2-BA4B-00A0C93EC93B)
    subprocess.run(
        [
            "sudo",
            "gpt",
            "add",
            "-b",
            "2048",
            "-s",
            "131072",
            "-t",
            "C12A7328-F81F-11D2-BA4B-00A0C93EC93B",
            device_node,
        ],
        check=True,
    )

    # Slice 1 corresponds to the EFI partition
    slice_node = f"{device_node}s1"

    # 4. Format as MS-DOS (FAT32)
    subprocess.run(["sudo", "newfs_msdos", "-F", "32", "-v", "EFI", slice_node], check=True)

    # 5. Mount and copy kernel as BOOTAA64.EFI
    mount_dir = os.path.join(assets_dir, "mnt_esp")
    os.makedirs(mount_dir, exist_ok=True)
    subprocess.run(["sudo", "mount", "-t", "msdos", slice_node, mount_dir], check=True)

    os.makedirs(os.path.join(mount_dir, "EFI", "BOOT"), exist_ok=True)
    shutil.copy(vmlinuz_path, os.path.join(mount_dir, "EFI", "BOOT", "BOOTAA64.EFI"))

    subprocess.run(["sudo", "umount", mount_dir], check=True)
    print("[+] GPT EFI boot disk constructed successfully at boot_disk.img!")

finally:
    subprocess.run(["hdiutil", "detach", device_node], capture_output=True)
