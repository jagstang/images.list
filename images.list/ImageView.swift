import UIKit

class ImageView: UIImageView {
    
    private let requestTimeout = Settings.ImageApi.requestTimeout
    
    private var currentTask: URLSessionTask?
    var imageUrlString: String?
    
    public func loadImage(fromURL url: String, completion: ((CGSize) -> ())? = nil) {
        weak var oldTask = currentTask
        currentTask = nil
        oldTask?.cancel()
        
        imageUrlString = url
        
        guard let imageURL = URL(string: url) else {
            return
        }
        
        let cache = URLCache.shared
        var request = URLRequest(url: imageURL)
        request.timeoutInterval = requestTimeout
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = cache.cachedResponse(for: request)?.data,
                let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.updateImageIfNeeded(image: image, fromUrl: url, completion: completion)
                }
            } else {
                let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                    if let data = data,
                        let response = response,
                        ((response as? HTTPURLResponse)?.statusCode ?? 500) < 300,
                        let image = UIImage(data: data) {
                        let cachedData = CachedURLResponse(response: response, data: data)
                        cache.storeCachedResponse(cachedData, for: request)
                        DispatchQueue.main.async {
                            self.updateImageIfNeeded(image: image, fromUrl: url, completion: completion)
                        }
                    }
                })
                self.currentTask = dataTask
                dataTask.resume()
            }
        }
    }
    
    private func updateImageIfNeeded(image: UIImage, fromUrl: String, completion: ((CGSize) -> ())? = nil) {
        if self.imageUrlString == fromUrl {
            if let completion = completion {
                completion(image.size)
            }
            self.image = image
        }
    }
}
