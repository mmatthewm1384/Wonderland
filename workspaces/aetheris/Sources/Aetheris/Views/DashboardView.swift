struct VirtualMachinesView: View {
    @ObservedObject var daemonClient: WonderlandDaemonClient

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Active Micro-Virtual Machines")
                .font(.headline)
                .foregroundColor(.accentColor)

            List(self.daemonClient.activeVMs) { vm in
                HStack {
                    Circle()
                        .fill(vm.isRunning ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(vm.id)
                        .font(.system(.body, design: .monospaced))
                    Spacer()
                    Text("vCPU: \(vm.vcpus) | RAM: \(vm.memoryMB)MB")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .frame(minHeight: 180)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}
