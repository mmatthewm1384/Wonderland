import os
import shutil
import subprocess

assets_dir = "/Users/wonderland/Developer/projects/aetheris/assets"
vmlinuz_path = os.path.join(assets_dir, "vmlinuz")
img_path = os.path.join(assets_dir, "efi_boot.img")

print("[+] Creating raw 64MB image file...")
if os.path.exists(img_path):
    os.remove(img_path)

# Create 64MB blank file
with open(img_path, "wb") as f:
    f.write(b"\0" * (64 * 1024 * 1024))

print("[+] Formatting image as FAT32...")
subprocess.run(["newfs_msdos", "-F", "32", "-v", "EFI", img_path], check=True)

print("[+] Attaching image to populate EFI payload...")
attach_out = subprocess.run(
    ["hdiutil", "attach", img_path, "-mountrandom", assets_dir],
    capture_output=True,
    text=True,
    check=True,
)

mount_point = None
for line in attach_out.stdout.splitlines():
    if "/Volumes/" in line:
        mount_point = line.split()[-1]
        break

if not mount_point:
    raise RuntimeError("Failed to locate mount point.")

print(f"[+] Mounted at {mount_point}. Setting up EFI/BOOT/BOOTAA64.EFI...")
os.makedirs(os.path.join(mount_point, "EFI", "BOOT"), exist_ok=True)
shutil.copy(vmlinuz_path, os.path.join(mount_point, "EFI", "BOOT", "BOOTAA64.EFI"))

print("[+] Detaching volume...")
subprocess.run(["hdiutil", "detach", mount_point], check=True)
print("[+] EFI boot disk image ready at efi_boot.img!")
