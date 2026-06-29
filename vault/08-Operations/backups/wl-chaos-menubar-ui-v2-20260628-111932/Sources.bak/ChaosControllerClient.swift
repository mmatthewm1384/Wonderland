import Foundation

struct ChaosControllerResponse: Decodable {
    let ok: Bool?
    let status: String?
    let message: String?
}

enum ChaosControllerClient {
    static let baseURL = URL(string: "http://127.0.0.1:9105")!

    static func execute(model: ChaosModel) async -> Bool {
        let url = baseURL.appendingPathComponent("/chaos/model")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 5
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": model.id,
            "command": model.command,
            "risk_level": model.riskLevel
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                return false
            }

            guard (200...299).contains(http.statusCode) else {
                return false
            }

            let decoded = try? JSONDecoder().decode(ChaosControllerResponse.self, from: data)

            return decoded?.ok ?? true
        } catch {
            return false
        }
    }
}
