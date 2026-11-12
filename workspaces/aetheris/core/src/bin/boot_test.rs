use wonderland_core::vm::EphemeralVM;
use std::{thread, time::{Duration, Instant}};

fn main() {
    println!("[AETHERIS-TEST] Starting Project Aetheris Ephemeral VM test harness...");

    let payload = b"echo 'AETHERIS_PAYLOAD_SUCCESS'\n";
    
    let mut vm = match EphemeralVM::spawn(512, payload) {
        Some(vm) => vm,
        None => {
            eprintln!("[AETHERIS-TEST] Failed to spawn EphemeralVM.");
            return;
        }
    };

    // Wait for guest init to load
    thread::sleep(Duration::from_secs(2));

    println!("[AETHERIS-TEST] Pushing payload via serial interface...");
    vm.write_serial(payload).expect("Failed to write serial payload");

    // Collect output from the channel with a timeout
    let timeout = Duration::from_secs(3);
    let start = Instant::now();
    let mut success_observed = false;

    while start.elapsed() < timeout {
        if let Ok(line) = vm.rx.try_recv() {
            if line.contains("AETHERIS_PAYLOAD_SUCCESS") {
                success_observed = true;
                break;
            }
        }
        thread::sleep(Duration::from_millis(50));
    }

    if success_observed {
        println!("[AETHERIS-TEST] PASSED: Successfully verified guest execution output in Rust harness.");
    } else {
        eprintln!("[AETHERIS-TEST] FAILED: Timed out waiting for guest execution confirmation.");
    }
}
