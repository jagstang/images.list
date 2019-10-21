import Foundation
import UIKit

enum ImageError {
    case client, server, json
}

protocol ImageProviderDelegate: class {
    func didRecieveDataUpdate()
    func didFailDataUpdateWithError(error: ImageError)
}

class ImageProvider: NSObject {
    
    weak var delegate: ImageProviderDelegate?
    
    private let requestPrefix = Settings.ImageApi.urlPrefix
    private let requestBatchSize = Settings.ImageApi.imagesBatchSize
    private let requestTimeout = Settings.ImageApi.requestTimeout
    
    private var page = 0
    
    private var images: [Image] = []
    
    var count: Int {
        return images.count
    }
    
    func getBy(id: Int) -> Image {
        return images[id]
    }
    
    func requestData() {
        let session = URLSession.shared
        let request = prepareGetRequest(for: page)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if error != nil || data == nil {
                print("Error while getting images: \(error!)")
                self.delegate?.didFailDataUpdateWithError(error: .client)
                return
            }

            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server sent error in response")
                self.delegate?.didFailDataUpdateWithError(error: .server)
                return
            }

            guard let mime = response.mimeType, mime == "application/json" else {
                print("Server sent wrong MIME type")
                self.delegate?.didFailDataUpdateWithError(error: .json)
                return
            }
            
            do {
                let imagesData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [Any]
                let images = self.extractRatesFromJson(data: imagesData)
                
                DispatchQueue.main.async {
                    for image in images {
                        self.images.append(image)
                    }
                    self.delegate?.didRecieveDataUpdate()
                }
                return
            } catch {
                print("Server sent wrong json format")
                self.delegate?.didFailDataUpdateWithError(error: .json)
                return
            }
        })
        
        task.resume()
    }
    
    func refreshData() {
        page = 0
        images = []
        delegate?.didRecieveDataUpdate()
        
        requestData()
    }
    
    func requestNextPage() {
        page += 1
        requestData()
    }
    
    private func prepareGetRequest(for page: Int) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: NSURL(string: getUrl(for: page))! as URL)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.cachePolicy = .reloadIgnoringCacheData
        request.timeoutInterval = requestTimeout
        
        return request
    }
    
    private func getUrl(for page: Int) -> String {
        return "\(requestPrefix)?limit=\(requestBatchSize)&page=\(page)&order=Desc"
    }
    
    private func extractRatesFromJson(data: [Any]) -> [Image] {
        var result = [Image]()
        
        for row in data {
            if let jsonRow = row as? [String: Any] {
                guard let url = jsonRow["url"] as? String,
                    let width = jsonRow["width"] as? Int,
                    let height = jsonRow["height"] as? Int else {
                        continue
                }
                
                guard let jsonData = try? JSONSerialization.data(withJSONObject: row, options: [.prettyPrinted]),
                    let prettyPrintedString = String(data: jsonData, encoding: .utf8) else { continue }
                
                result.append(Image(
                    url: url,
                    width: width,
                    height: height,
                    prettyJson: prettyPrintedString
                ))
            }
        }
        
        return result
    }
}
