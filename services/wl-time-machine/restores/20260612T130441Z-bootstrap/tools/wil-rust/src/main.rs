use chrono::Utc;
use serde_json::{json, Value};
use std::{
    env,
    fs,
    path::{Path, PathBuf},
    process::{Command, exit},
};

fn root() -> PathBuf {
    env::current_dir().expect("failed to get cwd")
}

fn load_json(path: &str) -> Value {
    let raw = fs::read_to_string(path).unwrap_or_else(|_| {
        println!("{}", json!({
            "result": "FAIL",
            "reason": "file not found",
            "path": path
        }));
        exit(1);
    });

    serde_json::from_str(&raw).unwrap_or_else(|e| {
        println!("{}", json!({
            "result": "FAIL",
            "reason": "invalid json",
            "error": e.to_string(),
            "path": path
        }));
        exit(1);
    })
}

fn parse_overrides(args: &[String]) -> Vec<(String, String)> {
    args.iter()
        .filter(|a| a.contains('=') && !a.starts_with("--"))
        .filter_map(|a| {
            let mut parts = a.splitn(2, '=');
            Some((parts.next()?.to_string(), parts.next()?.to_string()))
        })
        .collect()
}

fn interpolate(value: &mut Value, vars: &serde_json::Map<String, Value>) {
    match value {
        Value::String(s) => {
            for (k, v) in vars {
                let replacement = v.as_str().map(String::from).unwrap_or_else(|| v.to_string());
                *s = s.replace(&format!("${{{}}}", k), &replacement);
            }
        }
        Value::Array(arr) => {
            for item in arr {
                interpolate(item, vars);
            }
        }
        Value::Object(map) => {
            for (_, item) in map.iter_mut() {
                interpolate(item, vars);
            }
        }
        _ => {}
    }
}

fn apply_vars(mut doc: Value, overrides: Vec<(String, String)>) -> Value {
    if !doc.get("variables").is_some() {
        doc["variables"] = json!({});
    }

    for (k, v) in overrides {
        doc["variables"][k] = json!(v);
    }

    let vars = doc["variables"].as_object().cloned().unwrap_or_default();
    interpolate(&mut doc, &vars);
    doc
}

fn compile_doc(doc: &Value) -> Value {
    json!({
        "wil_version": doc.get("version").cloned().unwrap_or(json!(null)),
        "kind": doc.get("kind").cloned().unwrap_or(json!(null)),
        "id": doc.get("id").cloned().unwrap_or(json!(null)),
        "intent": doc.get("intent").cloned().unwrap_or(json!(null)),
        "variables": doc.get("variables").cloned().unwrap_or(json!({})),
        "requires": doc.get("requires").cloned().unwrap_or(json!([])),
        "do": doc.get("do").cloned().unwrap_or(json!([])),
        "prove": doc.get("prove").cloned().unwrap_or(json!([])),
        "outputs": doc.get("outputs").cloned().unwrap_or(json!([])),
        "recover": doc.get("recover").cloned().unwrap_or(json!([])),
        "rollback": doc.get("rollback").cloned().unwrap_or(json!([]))
    })
}

fn run_shell(command: &str) -> bool {
    Command::new("sh")
        .arg("-c")
        .arg(command)
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

fn run_actions(doc: &Value, section: &str) -> Vec<Value> {
    let mut results = vec![];

    if let Some(actions) = doc.get(section).and_then(|v| v.as_array()) {
        for action in actions {
            let name = action.get("name").and_then(|v| v.as_str()).unwrap_or("unnamed");
            let cmd = action.get("run").and_then(|v| v.as_str()).unwrap_or("");

            if cmd.is_empty() {
                results.push(json!({
                    "name": name,
                    "status": "FAIL",
                    "reason": "missing run command"
                }));
                break;
            }

            let ok = run_shell(cmd);

            results.push(json!({
                "name": name,
                "command": cmd,
                "status": if ok { "PASS" } else { "FAIL" }
            }));

            if !ok {
                break;
            }
        }
    }

    results
}

fn run_checks(doc: &Value, section: &str) -> Vec<Value> {
    let mut results = vec![];

    if let Some(checks) = doc.get(section).and_then(|v| v.as_array()) {
        for check in checks {
            let name = check.get("name").and_then(|v| v.as_str()).unwrap_or("unnamed");
            let cmd = check.get("command").and_then(|v| v.as_str()).unwrap_or("");

            if cmd.is_empty() {
                results.push(json!({
                    "name": name,
                    "status": "FAIL",
                    "reason": "missing command"
                }));
                continue;
            }

            let ok = run_shell(cmd);

            results.push(json!({
                "name": name,
                "command": cmd,
                "status": if ok { "PASS" } else { "FAIL" }
            }));
        }
    }

    results
}

fn inspect_outputs(doc: &Value) -> Vec<Value> {
    let mut results = vec![];
    let r = root();

    if let Some(outputs) = doc.get("outputs").and_then(|v| v.as_array()) {
        for item in outputs {
            let kind = item.get("kind").and_then(|v| v.as_str()).unwrap_or("unknown");
            let path = item.get("path").and_then(|v| v.as_str()).unwrap_or("");
            let full = r.join(path);

            let ok = match kind {
                "directory" => full.is_dir(),
                "file" => full.is_file(),
                _ => full.exists(),
            };

            results.push(json!({
                "kind": kind,
                "path": path,
                "status": if ok { "PASS" } else { "FAIL" }
            }));
        }
    }

    results
}

fn all_pass(items: &[Value]) -> bool {
    items.iter().all(|v| {
        v.get("status").and_then(|s| s.as_str()) == Some("PASS")
    })
}

fn write_event(doc: &Value, mode: &str, result: &str) -> String {
    let stamp = Utc::now().format("%Y%m%dT%H%M%SZ").to_string();
    let id = doc.get("id").and_then(|v| v.as_str()).unwrap_or("unknown");
    let event_id = format!("{}-{}-{}", stamp, id, mode);

    let dir = root().join("vault/09-Governance/wil/events");
    fs::create_dir_all(&dir).unwrap();

    let path = dir.join(format!("{}.event.json", event_id));

    let event = json!({
        "kind": "event",
        "id": event_id,
        "version": 0,
        "program": id,
        "mode": mode,
        "result": result,
        "occurred": stamp
    });

    fs::write(&path, serde_json::to_string_pretty(&event).unwrap()).unwrap();
    path.to_string_lossy().to_string()
}

fn write_audit(doc: &Value, mode: &str, payload: &Value) -> String {
    let stamp = Utc::now().format("%Y%m%dT%H%M%SZ").to_string();
    let id = doc.get("id").and_then(|v| v.as_str()).unwrap_or("unknown");
    let audit_id = format!("{}-{}-{}", stamp, id, mode);

    let dir = root().join("vault/09-Governance/wil/audit");
    fs::create_dir_all(&dir).unwrap();

    let path = dir.join(format!("{}.audit.json", audit_id));

    let audit = json!({
        "kind": "audit",
        "id": audit_id,
        "version": 0,
        "program": id,
        "mode": mode,
        "generated": stamp,
        "payload": payload
    });

    fs::write(&path, serde_json::to_string_pretty(&audit).unwrap()).unwrap();
    path.to_string_lossy().to_string()
}

fn emit_history(doc: &Value, mode: &str, payload: &mut Value) {
    let result = payload.get("result").and_then(|v| v.as_str()).unwrap_or("UNKNOWN");
    let event = write_event(doc, mode, result);
    payload["event"] = json!(event);
    let audit = write_audit(doc, mode, payload);
    payload["audit"] = json!(audit);
}

fn plan(doc: &Value) {
    println!("Program: {}", doc.get("id").and_then(|v| v.as_str()).unwrap_or(""));
    println!("Intent: {}", doc.get("intent").and_then(|v| v.as_str()).unwrap_or(""));
    println!();

    if let Some(actions) = doc.get("do").and_then(|v| v.as_array()) {
        println!("Actions:");
        for (i, action) in actions.iter().enumerate() {
            println!("{}. {}: {}", i + 1,
                action.get("name").and_then(|v| v.as_str()).unwrap_or("unnamed"),
                action.get("run").and_then(|v| v.as_str()).unwrap_or("")
            );
        }
    }
}

fn timeline() {
    let dir = root().join("vault/09-Governance/wil/events");
    let mut files: Vec<PathBuf> = fs::read_dir(dir)
        .unwrap_or_else(|_| fs::read_dir(".").unwrap())
        .filter_map(|e| e.ok().map(|e| e.path()))
        .filter(|p| p.extension().map(|e| e == "json").unwrap_or(false))
        .collect();

    files.sort();

    for path in files {
        if let Ok(raw) = fs::read_to_string(path) {
            if let Ok(data) = serde_json::from_str::<Value>(&raw) {
                println!(
                    "{}  {:<5}  {:<10}  {}",
                    data.get("occurred").and_then(|v| v.as_str()).unwrap_or(""),
                    data.get("result").and_then(|v| v.as_str()).unwrap_or(""),
                    data.get("mode").and_then(|v| v.as_str()).unwrap_or(""),
                    data.get("program").and_then(|v| v.as_str()).unwrap_or("")
                );
            }
        }
    }
}

fn status() {
    let base = root().join("vault/09-Governance/wil");

    fn count(base: &Path, sub: &str) -> usize {
        fs::read_dir(base.join(sub))
            .map(|rd| rd.filter_map(|e| e.ok()).count())
            .unwrap_or(0)
    }

    println!("WIL Status");
    println!();
    println!("Artifacts: {}", count(&base, "artifacts"));
    println!("Worlds:    {}", count(&base, "worlds"));
    println!("Intents:   {}", count(&base, "intents"));
    println!("Reports:   {}", count(&base, "reports"));
    println!("Events:    {}", count(&base, "events"));
    println!("Audits:    {}", count(&base, "audit"));
}



fn load_artifacts() -> Vec<Value> {
    let dir = root().join("vault/09-Governance/wil/artifacts");
    let mut artifacts = vec![];

    if let Ok(entries) = fs::read_dir(dir) {
        let mut paths: Vec<PathBuf> = entries
            .filter_map(|e| e.ok().map(|e| e.path()))
            .filter(|p| p.to_string_lossy().ends_with(".artifact.json"))
            .collect();

        paths.sort();

        for path in paths {
            if let Ok(raw) = fs::read_to_string(path) {
                if let Ok(data) = serde_json::from_str::<Value>(&raw) {
                    artifacts.push(data);
                }
            }
        }
    }

    artifacts
}


fn graph_text() {
    println!("WIL Reality Graph");
    println!();

    for data in load_artifacts() {
        let aid = data.get("id").and_then(|v| v.as_str()).unwrap_or("unknown");
        println!("{}", aid);

        if let Some(deps) = data.get("depends_on").and_then(|v| v.as_array()) {
            for dep in deps {
                if let Some(dep_id) = dep.as_str() {
                    println!("  -> {}", dep_id);
                }
            }
        }

        if let Some(caps) = data.get("capabilities").and_then(|v| v.as_array()) {
            if !caps.is_empty() {
                println!("  capabilities:");
                for cap in caps {
                    if let Some(cap_id) = cap.as_str() {
                        println!("    - {}", cap_id);
                    }
                }
            }
        }

        println!();
    }
}


fn graph_json() {
    let mut nodes = vec![];
    let mut edges = vec![];

    for data in load_artifacts() {
        let aid = data.get("id").and_then(|v| v.as_str()).unwrap_or("unknown");

        nodes.push(json!({
            "id": aid,
            "kind": data.get("kind").and_then(|v| v.as_str()).unwrap_or("artifact"),
            "type": data.get("type").and_then(|v| v.as_str()).unwrap_or("unknown"),
            "status": data.get("status").and_then(|v| v.as_str()).unwrap_or("unknown"),
            "authority": data.get("authority").cloned().unwrap_or(json!(null)),
            "capabilities": data.get("capabilities").cloned().unwrap_or(json!([]))
        }));

        if let Some(deps) = data.get("depends_on").and_then(|v| v.as_array()) {
            for dep in deps {
                if let Some(dep_id) = dep.as_str() {
                    edges.push(json!({
                        "from": aid,
                        "to": dep_id,
                        "type": "depends_on"
                    }));
                }
            }
        }
    }

    let graph = json!({
        "id": "wil-reality-graph-v0",
        "nodes": nodes,
        "edges": edges
    });

    let reports = root().join("vault/09-Governance/wil/reports");
    fs::create_dir_all(&reports).unwrap();

    let out = reports.join("wil-reality-graph.json");
    fs::write(&out, serde_json::to_string_pretty(&graph).unwrap()).unwrap();

    println!("{}", serde_json::to_string_pretty(&graph).unwrap());
}

fn world(world_id: &str) {
    let r = root();
    let world_path = r
        .join("vault/09-Governance/wil/worlds")
        .join(format!("{}.world.json", world_id));

    let artifact_dir = r.join("vault/09-Governance/wil/artifacts");

    if !world_path.exists() {
        println!("FAIL world not found: {}", world_id);
        exit(1);
    }

    let world_raw = fs::read_to_string(&world_path).expect("failed to read world");
    let world: Value = serde_json::from_str(&world_raw).expect("invalid world json");

    println!("World: {}", world.get("id").and_then(|v| v.as_str()).unwrap_or(""));
    println!("Status: {}", world.get("status").and_then(|v| v.as_str()).unwrap_or(""));
    println!();

    let mut passed = true;

    if let Some(items) = world.get("contains").and_then(|v| v.as_array()) {
        for item in items {
            let aid = item.as_str().unwrap_or("");
            let artifact_path = artifact_dir.join(format!("{}.artifact.json", aid));

            if !artifact_path.exists() {
                println!("FAIL artifact {} missing definition", aid);
                passed = false;
                continue;
            }

            println!("PASS artifact {} definition", aid);

            let raw = fs::read_to_string(&artifact_path).expect("failed to read artifact");
            let artifact: Value = serde_json::from_str(&raw).expect("invalid artifact json");

            if let Some(checks) = artifact.get("verify").and_then(|v| v.as_array()) {
                for check in checks {
                    let name = check.get("name").and_then(|v| v.as_str()).unwrap_or("unnamed");
                    let cmd = check.get("command").and_then(|v| v.as_str()).unwrap_or("");

                    if cmd.is_empty() {
                        println!("FAIL {}:{} missing command", aid, name);
                        passed = false;
                        continue;
                    }

                    let ok = run_shell(cmd);
                    println!("{} {}:{}", if ok { "PASS" } else { "FAIL" }, aid, name);

                    if !ok {
                        passed = false;
                    }
                }
            }

            println!();
        }
    }

    println!("RESULT {}", if passed { "PASS" } else { "FAIL" });
    exit(if passed { 0 } else { 1 });
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("usage: wil <command> [file] [--yes] [key=value]");
        exit(1);
    }

    let cmd = &args[1];

    if cmd == "status" {
        status();
        return;
    }

    if cmd == "timeline" {
        timeline();
        return;
    }

    if cmd == "graph" {
        graph_text();
        return;
    }

    if cmd == "graph-json" {
        graph_json();
        return;
    }

    if cmd == "world" {
        if args.len() < 3 {
            eprintln!("missing world id");
            exit(1);
        }

        world(&args[2]);
        return;
    }

    if args.len() < 3 {
        eprintln!("missing file");
        exit(1);
    }

    let file = &args[2];
    let doc = apply_vars(load_json(file), parse_overrides(&args[3..]));

    match cmd.as_str() {
        "compile" => println!("{}", serde_json::to_string_pretty(&compile_doc(&doc)).unwrap()),

        "plan" => plan(&doc),

        "inspect" => {
            let outputs = inspect_outputs(&doc);
            let passed = all_pass(&outputs);
            println!("{}", serde_json::to_string_pretty(&json!({
                "id": doc.get("id"),
                "kind": doc.get("kind"),
                "mode": "inspect",
                "result": if passed { "PASS" } else { "FAIL" },
                "outputs": outputs
            })).unwrap());
            exit(if passed { 0 } else { 1 });
        }

        "run" => {
            if !args.contains(&"--yes".to_string()) {
                eprintln!("Refusing to execute without --yes");
                exit(1);
            }

            let actions = run_actions(&doc, "do");
            let proof = run_checks(&doc, "prove");
            let outputs = inspect_outputs(&doc);
            let passed = all_pass(&actions) && all_pass(&proof) && all_pass(&outputs);

            let mut payload = json!({
                "id": doc.get("id"),
                "kind": doc.get("kind"),
                "mode": "run",
                "result": if passed { "PASS" } else { "FAIL" },
                "actions": actions,
                "proof": proof,
                "outputs": outputs
            });

            emit_history(&doc, "run", &mut payload);
            println!("{}", serde_json::to_string_pretty(&payload).unwrap());
            exit(if passed { 0 } else { 1 });
        }

        "recover" | "rollback" => {
            if !args.contains(&"--yes".to_string()) {
                eprintln!("Refusing to execute without --yes");
                exit(1);
            }

            let actions = run_actions(&doc, cmd);
            let outputs = inspect_outputs(&doc);
            let passed = all_pass(&actions);

            let mut payload = json!({
                "id": doc.get("id"),
                "kind": doc.get("kind"),
                "mode": cmd,
                "result": if passed { "PASS" } else { "FAIL" },
                "actions": actions,
                "outputs": outputs
            });

            emit_history(&doc, cmd, &mut payload);
            println!("{}", serde_json::to_string_pretty(&payload).unwrap());
            exit(if passed { 0 } else { 1 });
        }

        _ => {
            eprintln!("unknown command: {}", cmd);
            exit(1);
        }
    }
}
