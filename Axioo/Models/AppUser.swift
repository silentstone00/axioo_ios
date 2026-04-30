import Foundation

struct AppUser {
    var name: String
    var handle: String
    var userType: UserType
    var bio: String
    var following: Int
    var portfolioCount: Int

    enum UserType: String {
        case investor = "Investor"
        case founder  = "Founder"
        case scout    = "Scout"
    }
}
