import os
import shutil
import subprocess

assets_dir = "/Users/wonderland/Developer/projects/aetheris/assets"
vmlinuz_path = os.path.join(assets_dir, "vmlinuz")
efi_dmg = os.path.join(assets_dir, "efi.dmg")
mnt_efi = os.path.join(assets_dir, "mnt_efi")

print("[+] Constructing EFI volume...")
if os.path.exists(efi_dmg):
    os.remove(efi_dmg)

subprocess.run(
    ["hdiutil", "create", "-size", "64m", "-fs", "MS-DOS.FAT32", "-volname", "EFI", efi_dmg],
    check=True,
)
os.makedirs(mnt_efi, exist_ok=True)
subprocess.run(["hdiutil", "attach", efi_dmg, "-mountpoint", mnt_efi], check=True)

os.makedirs(os.path.join(mnt_efi, "EFI", "BOOT"), exist_ok=True)
shutil.copy(vmlinuz_path, os.path.join(mnt_efi, "EFI", "BOOT", "BOOTAA64.EFI"))

subprocess.run(["hdiutil", "detach", mnt_efi], check=True)
print("[+] EFI partition populated successfully as efi.dmg!")
