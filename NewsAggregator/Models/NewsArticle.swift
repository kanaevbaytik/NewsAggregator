
import Foundation

struct NewsResponse: Codable{
    let results: [NewsArticle]
}

struct NewsArticle: Codable, Equatable, Hashable {
    let title: String?
    let link: String?
    let pubDate: String?
    let image_url: String?
    let description: String?
    let creator: [String]?
    let keywords: [String]?
}
