import Foundation

enum ChaosControllerStatus {
    static let urls = [
        URL(string: "http://127.0.0.1:9105/api/v1/ready")!,
        URL(string: "http://127.0.0.1:9105/ready")!,
        URL(string: "http://127.0.0.1:9105/status")!
    ]

    static func checkSync() -> String {
        for url in urls {
            if isOnline(url: url) {
                return "🟢 Controller Online"
            }
        }
        return "🔴 Controller Offline"
    }

    private static func isOnline(url: URL) -> Bool {
        let sem = DispatchSemaphore(value: 0)
        var ok = false

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.timeoutInterval = 1.5

        URLSession.shared.dataTask(with: req) { _, response, _ in
            if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) {
                ok = true
            }
            sem.signal()
        }.resume()

        _ = sem.wait(timeout: .now() + 2)
        return ok
    }
}
