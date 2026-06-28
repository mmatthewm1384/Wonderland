import Foundation

enum ChaosControllerStatus {
    static let url = URL(string: "http://127.0.0.1:9105/health")!

    static func checkSync() -> String {
        let semaphore = DispatchSemaphore(value: 0)
        var result = "🔴 Controller Offline"

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 1.5

        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) {
                result = "🟢 Controller Online"
            }
            semaphore.signal()
        }.resume()

        _ = semaphore.wait(timeout: .now() + 2)
        return result
    }
}
