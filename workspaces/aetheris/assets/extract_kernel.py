import gzip
import sys

input_file = "vmlinuz"
output_file = "vmlinux.bin"

print(f"[*] Reading {input_file}...")
with open(input_file, "rb") as f:
    content = f.read()

# Find gzip magic bytes (1f 8b 08) which mark the start of the compressed kernel image
idx = content.find(b"\x1f\x8b\x08")
if idx != -1:
    print(f"[*] Found gzip payload at offset {idx}. Extracting...")
    compressed_data = content[idx:]
    try:
        decompressed = gzip.decompress(compressed_data)
        with open(output_file, "wb") as out:
            out.write(decompressed)
        print(f"[+] Successfully generated uncompressed kernel: {output_file}")
    except Exception as e:
        print(f"[-] Decompression failed: {e}")
        sys.exit(1)
else:
    print("[-] Gzip header not found. Trying direct decompression...")
    try:
        decompressed = gzip.decompress(content)
        with open(output_file, "wb") as out:
            out.write(decompressed)
        print(f"[+] Successfully unzipped to {output_file}")
    except Exception as e:
        print(f"[-] Error: Could not extract kernel: {e}")
        sys.exit(1)
