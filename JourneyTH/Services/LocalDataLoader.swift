import Foundation

protocol DataLoading {
    func load<T: Decodable>(_ filename: String, as type: T.Type) throws -> T
}

struct LocalDataLoader: DataLoading {
    private final class BundleMarker {}

    func load<T: Decodable>(_ filename: String, as type: T.Type) throws -> T {
        let bundle = Bundle.main.path(forResource: filename, ofType: "json") != nil ? Bundle.main : Bundle(for: BundleMarker.self)
        guard let url = bundle.url(forResource: filename, withExtension: "json") else {
            throw DataLoaderError.fileNotFound(filename)
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

enum DataLoaderError: Error {
    case fileNotFound(String)
}
