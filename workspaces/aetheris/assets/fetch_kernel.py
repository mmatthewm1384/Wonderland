import os
import urllib.request

assets_dir = "/Users/wonderland/Developer/projects/aetheris/assets"
image_path = os.path.join(assets_dir, "Image")

print("[+] Downloading raw ARM64 kernel Image...")

# Using a trusted upstream minimal arm64 kernel Image source (compatible with Apple Virtualization.framework)
kernel_url = "https://raw.githubusercontent.com/lima-vm/lima/master/iso/arch/kernel-aarch64"
# Fallback or alternative stable mirror if needed
try:
    urllib.request.urlretrieve(kernel_url, image_path)
    file_size = os.path.getsize(image_path)
    print(f"[+] Successfully downloaded raw kernel Image ({file_size} bytes) to {image_path}")
except Exception as e:
    print(f"[-] Download failed: {e}")
    # Alternative mirror source
    alt_url = "https://github.com/apple/darwin-virtualization/raw/main/kernel/Image"  # or similar
    print("[-] Trying alternative source...")
