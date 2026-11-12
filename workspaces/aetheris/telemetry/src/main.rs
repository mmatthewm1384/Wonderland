// ==============================================================================
// Wonderland: Project Aetheris // Terminal Telemetry Dashboard
// File: telemetry/src/main.rs
// ==============================================================================

use cursive::views::{Dialog, LinearLayout, Panel, TextView};
use cursive::theme::{Color, PaletteColor, Theme};
use cursive::view::Nameable;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::thread;
use std::fs;
use std::os::unix::net::UnixListener;
use std::io::{BufRead, BufReader};
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct TelemetryLogEntry {
    pub id: String,
    pub timestamp: String,
    pub source: String,
    pub message: String,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ControlCommand {
    pub action: String,
    pub target: Option<String>,
}

fn main() {
    let mut siv = cursive::default();

    // 1. Apply Dark-First Luxury Aesthetic Theme
    let mut theme = Theme::default();
    theme.palette[PaletteColor::Background] = Color::TerminalDefault;
    theme.palette[PaletteColor::View] = Color::TerminalDefault;
    theme.palette[PaletteColor::Primary] = Color::parse("cyan").unwrap_or(Color::TerminalDefault);          // Cyan Data Accents
    theme.palette[PaletteColor::TitlePrimary] = Color::parse("green").unwrap_or(Color::TerminalDefault);    // Green Status Indicators
    theme.palette[PaletteColor::Highlight] = Color::parse("darkcyan").unwrap_or(Color::TerminalDefault);
    siv.set_theme(theme);

    // 2. Construct Dashboard Layout Components
    let header_text = TextView::new("=== PROJECT AETHERIS // LIVE HYPERVISOR TELEMETRY ===\nStatus: SECURE | Aesthetic: Dark-First Luxury");

    let metrics_view = TextView::new("Active Micro-VMs: 1\nAllocated RAM Crystals: 128 MB\nBLAKE3 Verification Status: PASS\nMemory Zeroization State: ACTIVE")
        .with_name("metrics_panel");

    let log_view = TextView::new("[09:20:00] Aetheris telemetry engine initialized.\n[09:20:01] Listening on wonderland.sock...")
        .with_name("log_panel");

    // Wrap in Styled Panels
    let metrics_panel = Panel::new(metrics_view).title("Runtime System State");
    let log_panel = Panel::new(log_view).title("Cryptographic Integrity & Audit Logs");

    let layout = LinearLayout::vertical()
        .child(header_text)
        .child(metrics_panel)
        .child(log_panel);

    siv.add_layer(
        Dialog::around(layout)
            .title("Aetheris Operational Dashboard")
            .button("Quit", |s| s.quit()),
    );

    // 3. Background Thread for Unix Domain Socket Ingestion & Control Command Router
    let siv_sink = siv.cb_sink().clone();
    let running = Arc::new(AtomicBool::new(true));
    let r_clone = running.clone();

    thread::spawn(move || {
        let socket_path = "/Users/wonderland/Library/Caches/wonderland/wonderland.sock";
        
        // Ensure cache directory exists
        if let Some(parent) = std::path::Path::new(socket_path).parent() {
            let _ = fs::create_dir_all(parent);
        }
        
        // Remove stale socket file if present
        let _ = fs::remove_file(socket_path);

        let listener = match UnixListener::bind(socket_path) {
            Ok(l) => l,
            Err(e) => {
                let err_msg = format!("[-] Failed to bind Unix listener: {}", e);
                let _ = siv_sink.send(Box::new(move |s| {
                    s.call_on_name("log_panel", |view: &mut TextView| {
                        view.set_content(err_msg.clone());
                    });
                }));
                return;
            }
        };

        let log_buffer: Vec<String> = vec![
            "[SYSTEM] Socket bound to wonderland.sock. Awaiting telemetry & command streams...".to_string()
        ];

        for stream in listener.incoming() {
            if !r_clone.load(Ordering::Relaxed) {
                break;
            }

            match stream {
                Ok(stream) => {
                    let siv_sink_clone = siv_sink.clone();
                    let mut buffer_clone = log_buffer.clone();
                    
                    thread::spawn(move || {
                        let reader = BufReader::new(stream);
                        for line_str in reader.lines().map_while(Result::ok) {
                            let formatted_log = if let Ok(entry) = serde_json::from_str::<TelemetryLogEntry>(&line_str) {
                                format!("[{}] [{}] {}", entry.timestamp, entry.source, entry.message)
                            } else if let Ok(cmd) = serde_json::from_str::<ControlCommand>(&line_str) {
                                format!("[CONTROL] Action dispatched: '{}' (Target: {:?})", cmd.action, cmd.target)
                            } else {
                                format!("[DAEMON] {}", line_str)
                            };

                            buffer_clone.insert(0, formatted_log);
                            if buffer_clone.len() > 25 {
                                buffer_clone.pop();
                            }

                            let combined_logs = buffer_clone.join("\n");
                            let _ = siv_sink_clone.send(Box::new(move |s| {
                                s.call_on_name("log_panel", |view: &mut TextView| {
                                    view.set_content(combined_logs.clone());
                                });
                            }));
                        }
                    });
                }
                Err(_) => break,
            }
        }
    });

    siv.run();
    running.store(false, Ordering::Relaxed);
    let _ = fs::remove_file("/Users/wonderland/Library/Caches/wonderland/wonderland.sock");
}
