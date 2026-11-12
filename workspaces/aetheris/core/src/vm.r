use std::process::{Child, Command, Stdio};
use std::io::{BufRead, BufReader, Write};
use std::thread;

pub struct EphemeralVM {
    child: Child,
}

impl EphemeralVM {
    pub fn spawn(memory_mb: u64, _payload: &[u8]) -> Option<Self> {
        let mut child = Command::new("qemu-system-aarch64")
            .arg("-machine")
            .arg("virt")
            .arg("-accel")
            .arg("hvf")
            .arg("-cpu")
            .arg("max")
            .arg("-m")
            .arg(&format!("{}M", memory_mb))
            .arg("-smp")
            .arg("2")
            .arg("-kernel")
            .arg("assets/vmlinuz-virt")
            // Pass rootfs as a virtio-blk drive
            .arg("-drive")
            .arg("file=assets/rootfs.img,format=raw,id=hd0,if=none")
            .arg("-device")
            .arg("virtio-blk-device,drive=hd0")
            .arg("-net")
            .arg("none")
            .arg("-nographic")
            .arg("-append")
            .arg("console=ttyAMA0 root=/dev/vda rw panic=1")
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .spawn()
            .ok()?;

        let stdout = child.stdout.take()?;
        let stderr = child.stderr.take()?;

        thread::spawn(move || {
            let reader = BufReader::new(stdout);
            for line in reader.lines() {
                if let Ok(content) = line {
                    println!("[AETHERIS-GUEST-OUT] {}", content);
                }
            }
        });

        thread::spawn(move || {
            let reader = BufReader::new(stderr);
            for line in reader.lines() {
                if let Ok(content) = line {
                    eprintln!("[AETHERIS-GUEST-ERR] {}", content);
                }
            }
        });

        Some(Self { child })
    }

    pub fn write_serial(&mut self, data: &[u8]) -> std::io::Result<()> {
        if let Some(ref mut stdin) = self.child.stdin {
            stdin.write_all(data)?;
            stdin.flush()?;
        }
        Ok(())
    }
}

impl Drop for EphemeralVM {
    fn drop(&mut self) {
        println!("[AETHERIS-CORE] Terminating QEMU VM subprocess...");
        let _ = self.child.kill();
        let _ = self.child.wait();
    }
}
