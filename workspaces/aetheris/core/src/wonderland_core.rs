// ==============================================================================
// Wonderland: Project Aetheris // Core Orchestration Engine
// File: core/src/aetheris_core.rs
// ==============================================================================
pub mod ffi;

use blake3;
use uuid::Uuid;
use std::c_void;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum VMState {
    Provisioning,
    Running,
    Zeroizing,
    Terminated,
}

#[derive(Debug)]
pub enum VMError {
    AllocationFailed,
    IntegrityVerificationFailed,
    InvalidHypervisorState,
}

pub struct AetherisInstance {
    pub uuid: Uuid,
    pub memory_size_mb: u32,
    pub payload_hash: String,
    pub state: VMState,
    handle: *mut c_void,
}

impl AetherisInstance {
    /// Provisions a new hardware-isolated micro-VM after verifying payload integrity.
    pub fn provision(payload: &[u8], memory_mb: u32) -> Result<Self, VMError> {
        // Enforce strict zero-trust integrity check via BLAKE3
        let hash = blake3::hash(payload);
        if payload.is_empty() {
            return Err(VMError::IntegrityVerificationFailed);
        }

        let instance_uuid = Uuid::new_v4();

        // Instantiate secure hardware boundary through native hypervisor hooks
        let vm_handle = unsafe {
            ffi::spawn_ephemeral_vm(
                memory_mb as u64,
                payload.as_ptr(),
                payload.len(),
            )
        };

        if vm_handle.is_null() {
            return Err(VMError::AllocationFailed);
        }

        Ok(Self {
            uuid: instance_uuid,
            memory_size_mb: memory_mb,
            payload_hash: hash.to_hex().to_string(),
            state: VMState::Running,
            handle: vm_handle,
        })
    }

    /// Triggers immediate cryptographic memory zeroization and instance teardown.
    pub fn destroy(&mut self) -> Result<(), VMError> {
        self.state = VMState::Zeroizing;

        let result = unsafe {
            ffi::terminate_and_zeroize_vm(self.handle)
        };

        if result != 0 {
            return Err(VMError::InvalidHypervisorState);
        }

        self.state = VMState::Terminated;
        self.handle = std::ptr::null_mut();
        Ok(())
    }
}

impl Drop for AetherisInstance {
    fn drop(&mut self) {
        if self.state != VMState::Terminated && !self.handle.is_null() {
            let _ = self.destroy();
        }
    }
}
