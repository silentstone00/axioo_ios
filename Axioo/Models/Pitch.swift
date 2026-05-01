import SwiftUI

struct Pitch: Identifiable {
    var id = UUID()
    let startupName: String
    let tagline: String
    let founderName: String
    let founderTitle: String
    let category: String
    let stage: String
    var likes: Int
    var saves: Int
    let views: Int
    let trendingScore: Int
    var isLiked: Bool = false
    var isSaved: Bool = false
    let colors: [Color]
    let locationTag: String
    let raised: String?
    // Populated asynchronously by AppViewModel via PexelsService
    var videoURL: URL? = nil
}

// MARK: - Sample data (sorted by trendingScore)
extension Pitch {
    static let sampleFeed: [Pitch] = [
        Pitch(
            startupName: "VEIL",
            tagline: "Privacy-first analytics that never tracks your users.",
            founderName: "Priya Nair",
            founderTitle: "CEO",
            category: "Privacy · Analytics",
            stage: "Series A",
            likes: 4102, saves: 634, views: 29700,
            trendingScore: 99,
            colors: [Color(hex: "201E1F"), Color(hex: "685BC7"), Color(hex: "2D2360")],
            locationTag: "London, UK",
            raised: "$4.8M raised"
        ),
        Pitch(
            startupName: "NOVA",
            tagline: "AI that writes your investor updates in 30 seconds.",
            founderName: "Sarah Chen",
            founderTitle: "CEO & Co-Founder",
            category: "AI · SaaS",
            stage: "Seed",
            likes: 2847, saves: 412, views: 18200,
            trendingScore: 95,
            colors: [Color(hex: "685BC7"), Color(hex: "201E1F"), Color(hex: "3B2F8F")],
            locationTag: "San Francisco, CA",
            raised: "$1.2M raised"
        ),
        Pitch(
            startupName: "ECHO",
            tagline: "Voice journaling powered by emotional intelligence.",
            founderName: "Aisha Williams",
            founderTitle: "Founder & CEO",
            category: "Health · Consumer",
            stage: "Pre-seed",
            likes: 3287, saves: 521, views: 22100,
            trendingScore: 91,
            colors: [Color(hex: "FE572A"), Color(hex: "685BC7"), Color(hex: "8B1E0E")],
            locationTag: "Austin, TX",
            raised: nil
        ),
        Pitch(
            startupName: "KERN",
            tagline: "Design infrastructure for teams that ship fast.",
            founderName: "Marcus Okafor",
            founderTitle: "Founder",
            category: "Design · Dev Tools",
            stage: "Pre-seed",
            likes: 1923, saves: 287, views: 11400,
            trendingScore: 88,
            colors: [Color(hex: "FE572A"), Color(hex: "201E1F"), Color(hex: "5A1A0A")],
            locationTag: "New York, NY",
            raised: nil
        ),
        Pitch(
            startupName: "LUMEN",
            tagline: "Personalized learning paths built from your calendar.",
            founderName: "David Osei",
            founderTitle: "Founder",
            category: "EdTech · AI",
            stage: "Pre-seed",
            likes: 2654, saves: 389, views: 16800,
            trendingScore: 87,
            colors: [Color(hex: "FE572A"), Color(hex: "201E1F"), Color(hex: "3D0E00")],
            locationTag: "Lagos, NG",
            raised: nil
        ),
        Pitch(
            startupName: "STRATA",
            tagline: "The operating system for climate-focused funds.",
            founderName: "Tom Bergmann",
            founderTitle: "CEO",
            category: "Climate · Finance",
            stage: "Seed",
            likes: 2134, saves: 367, views: 15300,
            trendingScore: 83,
            colors: [Color(hex: "0A2818"), Color(hex: "1A4D2E"), Color(hex: "201E1F")],
            locationTag: "Stockholm, SE",
            raised: "$2.1M raised"
        ),
        Pitch(
            startupName: "DRIFT",
            tagline: "Autonomous expense management for remote-first teams.",
            founderName: "Keiko Tanaka",
            founderTitle: "Co-Founder",
            category: "Fintech · HR",
            stage: "Series A",
            likes: 1876, saves: 243, views: 13200,
            trendingScore: 79,
            colors: [Color(hex: "685BC7"), Color(hex: "FE572A"), Color(hex: "201E1F")],
            locationTag: "Tokyo, JP",
            raised: "$3.5M raised"
        ),
        Pitch(
            startupName: "FLUX",
            tagline: "Real-time supply chain visibility for manufacturers.",
            founderName: "James Park",
            founderTitle: "Co-Founder & CTO",
            category: "Logistics · B2B",
            stage: "Seed",
            likes: 1456, saves: 198, views: 8900,
            trendingScore: 76,
            colors: [Color(hex: "0E2A1E"), Color(hex: "1C5236"), Color(hex: "201E1F")],
            locationTag: "Berlin, DE",
            raised: "$800K raised"
        ),
    ]
}
