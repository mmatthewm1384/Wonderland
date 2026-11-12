import os
import shutil
import subprocess

assets_dir = "/Users/wonderland/Developer/projects/aetheris/assets"
vmlinuz_path = os.path.join(assets_dir, "vmlinuz")
img_path = os.path.join(assets_dir, "efi_boot.img")

print("[+] Creating 64MB raw disk image...")
if os.path.exists(img_path):
    os.remove(img_path)

with open(img_path, "wb") as f:
    f.write(b"\0" * (64 * 1024 * 1024))

print("[+] Attaching raw image as a virtual device node...")
attach_out = subprocess.run(
    ["hdiutil", "attach", "-nomount", img_path], capture_output=True, text=True, check=True
)
device_node = attach_out.stdout.strip().split()[0]
print(f"[+] Attached to {device_node}")

try:
    print("[+] Formatting node as MS-DOS (FAT32)...")
    subprocess.run(["newfs_msdos", "-F", "32", "-v", "EFI", device_node], check=True)

    mount_dir = os.path.join(assets_dir, "mnt_efi")
    os.makedirs(mount_dir, exist_ok=True)

    print("[+] Mounting device node...")
    subprocess.run(["mount", "-t", "msdos", device_node, mount_dir], check=True)

    print("[+] Populating EFI/BOOT/BOOTAA64.EFI...")
    os.makedirs(os.path.join(mount_dir, "EFI", "BOOT"), exist_ok=True)
    shutil.copy(vmlinuz_path, os.path.join(mount_dir, "EFI", "BOOT", "BOOTAA64.EFI"))

    subprocess.run(["umount", mount_dir], check=True)
    print("[+] EFI boot disk created successfully at efi_boot.img!")

finally:
    subprocess.run(["hdiutil", "detach", device_node], capture_output=True)
