mod chaos_contract;
#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
  tauri::Builder::default()
    .invoke_handler(tauri::generate_handler![chaos_contract::read_chaos_contract])
        .run(tauri::generate_context!())
    .expect("error while running tauri application");
}
