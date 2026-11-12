import os
import subprocess

disk_path = "/Users/wonderland/Developer/projects/aetheris/assets/efi_boot.img"

if os.path.exists(disk_path):
    os.remove(disk_path)

print("[+] Creating direct FAT32 EFI disk image via hdiutil...")
subprocess.run(
    ["hdiutil", "create", "-size", "64m", "-volname", "EFI", "-fs", "MS-DOS", disk_path], check=True
)

print("[+] EFI disk image successfully created.")
