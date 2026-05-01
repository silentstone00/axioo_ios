import Foundation

// MARK: - Pexels Videos API
// Get your free key at https://www.pexels.com/api/
// 20,000 requests/month on the free tier.
struct PexelsService {

    // ← Paste your Pexels API key here
    static let apiKey = "fpm6sCDKgSzr9mkzx1ZdHOU7tmSTm3NSk1xVqc8eyn1pwg2Vq7J1IndK"

    struct PexelsResult {
        let videoURL: URL
        let thumbnailURL: URL?
    }

    // MARK: - Response shapes
    private struct PopularResponse: Decodable {
        let videos: [Video]
    }
    private struct Video: Decodable {
        let image: String
        let video_files: [VideoFile]
        let video_pictures: [VideoPicture]?
    }
    private struct VideoFile: Decodable {
        let link: String
        let quality: String
        let width: Int
        let height: Int
    }
    private struct VideoPicture: Decodable {
        let picture: String
        let nr: Int
    }

    // MARK: - Fetch popular videos
    // No portrait filter — resizeAspectFill crops landscape video to fill portrait frames.
    static func fetchPopularPortraitURLs(count: Int = 15) async -> [PexelsResult] {
        guard !apiKey.isEmpty, apiKey != "YOUR_PEXELS_API_KEY" else { return [] }

        var comps = URLComponents(string: "https://api.pexels.com/videos/popular")!
        comps.queryItems = [
            .init(name: "per_page", value: "\(min(count, 80))")
        ]

        var req = URLRequest(url: comps.url!)
        req.setValue(apiKey, forHTTPHeaderField: "Authorization")

        guard let (data, _) = try? await URLSession.shared.data(for: req),
              let resp = try? JSONDecoder().decode(PopularResponse.self, from: data)
        else { return [] }

        return resp.videos.compactMap { video in
            let file = video.video_files.first(where: { $0.quality == "hd" })
                    ?? video.video_files.first
            guard let videoURL = file.flatMap({ URL(string: $0.link) }) else { return nil }
            let thumbStr = !video.image.isEmpty ? video.image
                         : video.video_pictures?.min(by: { $0.nr < $1.nr })?.picture ?? ""
            return PexelsResult(videoURL: videoURL, thumbnailURL: URL(string: thumbStr))
        }
    }
}
