#ifndef WonderlandCore_h
#define WonderlandCore_h

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

// SIMD Vector Engine & Benchmarking FFI exports from wonderland_core
void wonderland_simd_benchmark_run(void);
double wonderland_get_last_vector_throughput(void);

// Memory Crystal Cryptographic Verification FFI
bool wonderland_verify_crystal_hash(const char *hash_str);

// Micro-VM Lifecycle FFI
bool wonderland_vm_spawn(void);
void wonderland_vm_halt(void);
bool wonderland_vm_is_active(void);

#ifdef __cplusplus
}
#endif

#endif /* WonderlandCore_h */
