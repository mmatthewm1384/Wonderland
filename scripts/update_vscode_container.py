import os
import re
import sys
import tempfile


def main():
    settings_path = os.path.expanduser("~/Library/Application Support/Code/User/settings.json")
    if not os.path.exists(settings_path):
        print(f"Error: settings.json not found at {settings_path}")
        sys.exit(1)

    with open(settings_path) as f:
        content = f.read()

    match = re.search(r"\"container-tools\.containerRuntime\"\s*:\s*\"([^\"]+)\"", content)
    current = match.group(1) if match else "podman"

    arg = sys.argv[1] if len(sys.argv) > 1 else ""
    if arg in ["podman", "nerdctl"]:
        target = arg
    else:
        target = "nerdctl" if current == "podman" else "podman"

    # Define full mapping for each backend
    if target == "nerdctl":
        config = {
            "containers.containerClient": "com.microsoft.visualstudio.containers.nerdctl",
            "containers.orchestratorClient": "com.microsoft.visualstudio.orchestrators.nerdctlcompose",
            "docker.host": "unix:///Users/wonderland/.colima/default/docker.sock",
            "docker.dockerPath": "nerdctl",
            "container-tools.containerRuntime": "nerdctl",
        }
    else:
        config = {
            "containers.containerClient": "com.microsoft.visualstudio.containers.podman",  # or default podman client
            "containers.orchestratorClient": "com.microsoft.visualstudio.containers.podman",
            "docker.host": "unix:///Users/wonderland/.local/share/containers/podman/machine/qemu/podman.sock",
            "docker.dockerPath": "podman",
            "container-tools.containerRuntime": "podman",
        }

    def set_key(content, key, val):
        pattern = rf'("{key}"\s*:\s*)"[^"]*"'
        if re.search(pattern, content):
            return re.sub(pattern, rf'\1"{val}"', content)
        else:
            idx = content.rfind("}")
            if idx != -1:
                prefix = content[:idx].rstrip()
                comma = "," if not prefix.endswith(",") and not prefix.endswith("{") else ""
                return prefix + comma + f'\n  "{key}": "{val}"\n' + content[idx:]
            return content

    for key, val in config.items():
        content = set_key(content, key, val)

    dir_name = os.path.dirname(settings_path)
    with tempfile.NamedTemporaryFile("w", dir=dir_name, delete=False) as tf:
        tf.write(content)
        temp_name = tf.name

    os.replace(temp_name, settings_path)
    os.utime(settings_path, None)

    print(f"TARGET:{target}")
    print(f"HOST:{config['docker.host']}")


if __name__ == "__main__":
    main()
