pub mod vm;
pub mod crystal;
pub mod vector;
pub mod ffi;

#[cfg(feature = "python")]
use pyo3::prelude::*;

#[cfg(feature = "python")]
#[pymodule]
fn wonderland_core(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_class::<vector::VectorEngine>()?;
    Ok(())
}
