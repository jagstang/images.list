class Settings {
    
    class Cache {
        static let memoryCapacity = 100 * 1024 * 1024
        static let diskCapacity = 100 * 1024 * 1024
        static let diskPath = "urlCache"
    }
    
    class ImageApi {
        static let urlPrefix = "https://api.thecatapi.com/v1/images/search"
        static let imagesBatchSize = 50
        static let requestTimeout = 5.0
    }
}
