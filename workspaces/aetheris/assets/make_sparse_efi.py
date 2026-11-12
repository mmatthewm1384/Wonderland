import os
import shutil
import subprocess

assets_dir = "/Users/wonderland/Developer/projects/aetheris/assets"
vmlinuz_path = os.path.join(assets_dir, "vmlinuz")
sparse_path = os.path.join(assets_dir, "efi_boot.sparseimage")

print("[+] Creating sparse disk image...")
if os.path.exists(sparse_path):
    os.remove(sparse_path)

# Create a sparse image formatted as MS-DOS FAT32 directly
subprocess.run(
    [
        "hdiutil",
        "create",
        "-size",
        "64m",
        "-fs",
        "MS-DOS.FAT32",
        "-volname",
        "EFI",
        "-type",
        "SPARSE",
        sparse_path,
    ],
    check=True,
)

print("[+] Mounting sparse image...")
attach_out = subprocess.run(
    ["hdiutil", "attach", sparse_path, "-mountrandom", assets_dir],
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
    raise RuntimeError("Failed to locate mount point for sparse image.")

print(f"[+] Mounted at {mount_point}. Setting up EFI/BOOT/BOOTAA64.EFI...")
os.makedirs(os.path.join(mount_point, "EFI", "BOOT"), exist_ok=True)
shutil.copy(vmlinuz_path, os.path.join(mount_point, "EFI", "BOOT", "BOOTAA64.EFI"))

print("[+] Detaching volume...")
subprocess.run(["hdiutil", "detach", mount_point], check=True)
print(f"[+] EFI sparse boot disk ready at {sparse_path}!")
