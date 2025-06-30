import Foundation
import CloudKit

struct CloudHighScore: Identifiable {
    let id: CKRecord.ID
    let player: String
    let score: Int
    let date: Date?
}
