
use serde::Serialize;
use std::{
    collections::HashMap,
    fs,
    path::{Path, PathBuf},
    sync::{
        atomic::{AtomicBool, Ordering},
        Arc,
    },
    thread,
    time::{Duration, SystemTime},
};
use tauri::{AppHandle, Emitter, Manager, State};

struct WatchState {
    running: Arc<AtomicBool>,
}

#[derive(Clone, Serialize)]
struct MatrixFluderationEvent {
    kind: String,
    path: String,
}

#[derive(Clone, PartialEq, Eq)]
struct FileSig {
    modified: Option<SystemTime>,
    len: u64,
}

fn scan_dir(root: &Path, out: &mut HashMap<PathBuf, FileSig>) {
    if let Ok(entries) = fs::read_dir(root) {
        for entry in entries.flatten() {
            let path = entry.path();

            if path.file_name().and_then(|s| s.to_str()) == Some(".git") {
                continue;
            }

            if let Ok(meta) = entry.metadata() {
                if meta.is_dir() {
                    scan_dir(&path, out);
                } else {
                    out.insert(
                        path,
                        FileSig {
                            modified: meta.modified().ok(),
                            len: meta.len(),
                        },
                    );
                }
            }
        }
    }
}

fn emit(app: &AppHandle, kind: &str, path: PathBuf) {
    let _ = app.emit(
        "matrix-fluderation-event",
        MatrixFluderationEvent {
            kind: kind.to_string(),
            path: path.to_string_lossy().to_string(),
        },
    );
}

#[tauri::command]
fn home_dir() -> Result<String, String> {
    std::env::var("HOME")
        .map_err(|_| "Unable to resolve HOME environment variable".to_string())
}

#[tauri::command]
fn start_watch(app: AppHandle, state: State<WatchState>, path: String) -> Result<(), String> {
    let root = PathBuf::from(path.clone());

    if !root.exists() {
        return Err(format!("Watch path does not exist: {}", path));
    }

    state.running.store(false, Ordering::SeqCst);
    thread::sleep(Duration::from_millis(100));
    state.running.store(true, Ordering::SeqCst);

    let running = state.running.clone();

    thread::spawn(move || {
        let mut previous = HashMap::new();
        scan_dir(&root, &mut previous);

        while running.load(Ordering::SeqCst) {
            thread::sleep(Duration::from_millis(750));

            let mut current = HashMap::new();
            scan_dir(&root, &mut current);

            for (path, sig) in current.iter() {
                match previous.get(path) {
                    None => emit(&app, "CREATE", path.clone()),
                    Some(old) if old != sig => emit(&app, "MODIFY", path.clone()),
                    _ => {}
                }
            }

            for path in previous.keys() {
                if !current.contains_key(path) {
                    emit(&app, "REMOVE", path.clone());
                }
            }

            previous = current;
        }
    });

    Ok(())
}

#[tauri::command]
fn stop_watch(state: State<WatchState>) -> Result<(), String> {
    state.running.store(false, Ordering::SeqCst);
    Ok(())
}

fn main() {
    tauri::Builder::default()
        .manage(WatchState {
            running: Arc::new(AtomicBool::new(false)),
        })
        .invoke_handler(tauri::generate_handler![home_dir, start_watch, stop_watch])
        .run(tauri::generate_context!())
        .expect("error while running Matrix Fluderation");
}
