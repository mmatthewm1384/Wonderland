use std::fs;
use std::path::PathBuf;

#[tauri::command]
pub fn read_chaos_contract() -> Result<String, String> {
    let home = std::env::var("HOME")
        .map_err(|e| format!("HOME unavailable: {e}"))?;

    let path: PathBuf = [
        home.as_str(),
        "Wonderland",
        "vault",
        "chaos",
        "visual-chaos-contract.json",
    ]
    .iter()
    .collect();

    fs::read_to_string(&path)
        .map_err(|e| format!("failed to read {}: {e}", path.display()))
}
