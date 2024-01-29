import UIKit


protocol APIRequest {
    associatedtype Response
    
    var urlRequest: URLRequest { get }
    func decodeData(_ data: Data) throws -> Response
}

struct PhotoInfo: Codable {
    let title: String
    let url: URL
    let explanation: String
}

struct ImageURL {
    let imageURL: UIImage
}

struct PhotoInfoAPIRequest: APIRequest {
    var urlRequest: URLRequest {
        var components = URLComponents(string: "https://api.nasa.gov/planetary/apod")!
        let apiKeyQueryItem = URLQueryItem(name: "api_key", value: "IpwO2BPrF8reUFKsGfW5Wja4lAHBqHthOZhuGfLz")
        components.queryItems = [apiKeyQueryItem]
        return URLRequest(url: components.url!)
    }
    
    func decodeData(_ data: Data) throws -> PhotoInfo {
        let decoder = JSONDecoder()
        return try decoder.decode(PhotoInfo.self, from: data)
    }
    
}

struct ImageAPIRequest: APIRequest {
    var urlRequest: URLRequest {
        var componets = URLComponents(string: "https://apod.nasa.gov/apod/image/2401/VenusPhases_Gonzales_960.jpg")!
        return URLRequest(url: componets.url!)
    }
    
    func decodeData(_ data: Data) throws -> UIImage {
        let image = UIImage(data: data)
        return image!
    }
}

enum APIError: Error {
    case youSuck
}

func sendRequest<Request: APIRequest>(_ request: Request) async throws -> Request.Response {
    let session = URLSession.shared
    let (data, response) = try await session.data(for: request.urlRequest)
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
        throw APIError.youSuck
    }
    return try request.decodeData(data)
}

func getPhotoOfTheDay() {
    Task {
        do {
            let response = try await sendRequest(PhotoInfoAPIRequest())
            print(response)
        } catch {
            print(error.localizedDescription)
        }
    }
}

func getPicture() {
    Task {
        do {
            let image = try await sendRequest(ImageAPIRequest())
        } catch {
            print(error.localizedDescription)
        }
    }
}
//getPhotoOfTheDay()
getPicture()
