import os
import shutil
import subprocess

assets_dir = "/Users/Wonderland/wonderland/workspaces/aetheris/assets"
vmlinuz_path = os.path.join(assets_dir, "vmlinuz")
dmg_path = os.path.join(assets_dir, "efi_boot.dmg")

print("[+] Creating clean FAT32 volume for EFI boot...")
if os.path.exists(dmg_path):
    os.remove(dmg_path)

# Create a standard 64MB FAT32 disk image using hdiutil (supported layout SPUD)
subprocess.run(
    ["hdiutil", "create", "-size", "64m", "-fs", "MS-DOS.FAT32", "-volname", "EFI", dmg_path],
    check=True,
)

print("[+] Mounting image to populate files...")
attach_out = subprocess.run(
    ["hdiutil", "attach", dmg_path, "-mountrandom", assets_dir],
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
    raise RuntimeError("Failed to find mount point.")

print(f"[+] Mounted at {mount_point}. Setting up EFI/BOOT/BOOTAA64.EFI...")
os.makedirs(os.path.join(mount_point, "EFI", "BOOT"), exist_ok=True)
shutil.copy(vmlinuz_path, os.path.join(mount_point, "EFI", "BOOT", "BOOTAA64.EFI"))

print("[+] Detaching volume...")
subprocess.run(["hdiutil", "detach", mount_point], check=True)
print("[+] EFI boot disk image ready at efi_boot.dmg!")
