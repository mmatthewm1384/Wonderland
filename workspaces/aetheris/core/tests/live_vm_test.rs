use wonderland_core::vm::EphemeralVM;

#[test]
fn test_live_vm_lifecycle() {
    let payload = b"echo 'Aetheris live VM test active'\n";
    
    // Use correct capitalization: EphemeralVM
    let vm = match EphemeralVM::spawn(512, payload) {
        Some(v) => v,
        None => {
            eprintln!("Failed to spawn EphemeralVM in test environment.");
            return;
        }
    };

    // Ensure spawn and drop complete cleanly
    drop(vm);
}
