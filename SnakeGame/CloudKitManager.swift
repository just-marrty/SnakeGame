import Foundation
import CloudKit
import os

struct CloudKitManager {
    static let database = CKContainer.default().publicCloudDatabase
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.martin.snake", category: "CloudKit")

    static func saveHighScore(playerName: String, score: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let predicate = NSPredicate(format: "CD_playerName == %@", playerName)
        let query = CKQuery(recordType: "CD_HighScore", predicate: predicate)

        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 1

        var fetchedRecord: CKRecord?

        operation.recordMatchedBlock = { _, result in
            switch result {
            case .success(let record):
                fetchedRecord = record
            case .failure(let error):
                logger.error("Fetch error for player \(playerName): \(error.localizedDescription)")
            }
        }

        operation.queryResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let existingRecord = fetchedRecord {
                        let existingScore = existingRecord["CD_score"] as? Int ?? 0
                        if score > existingScore {
                            existingRecord["CD_score"] = score as CKRecordValue
                            existingRecord["CD_date"] = Date() as CKRecordValue

                            logger.debug("Aktualizuji skóre pro \(playerName): \(score)")

                            database.save(existingRecord) { _, error in
                                DispatchQueue.main.async {
                                    if let error = error {
                                        logger.error("Chyba při aktualizaci skóre: \(error.localizedDescription)")
                                        completion(.failure(error))
                                    } else {
                                        logger.debug("Skóre úspěšně aktualizováno.")
                                        completion(.success(()))
                                    }
                                }
                            }
                        } else {
                            logger.debug("Nové skóre není vyšší než stávající. Neukládám.")
                            completion(.success(()))
                        }

                    } else {
                        let newRecord = CKRecord(recordType: "CD_HighScore")
                        newRecord["CD_playerName"] = playerName as CKRecordValue
                        newRecord["CD_score"] = score as CKRecordValue
                        newRecord["CD_date"] = Date() as CKRecordValue

                        logger.debug("Vytvářím nový záznam pro \(playerName) se skóre \(score)")

                        database.save(newRecord) { _, error in
                            DispatchQueue.main.async {
                                if let error = error {
                                    logger.error("Chyba při vytváření záznamu: \(error.localizedDescription)")
                                    completion(.failure(error))
                                } else {
                                    logger.debug("Nové skóre uloženo.")
                                    completion(.success(()))
                                }
                            }
                        }
                    }

                case .failure(let error):
                    logger.error("Chyba při dotazu na CloudKit: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }

        database.add(operation)
    }

    static func fetchTopScores(limit: Int = 10, completion: @escaping (Result<[CloudHighScore], Error>) -> Void) {
        let query = CKQuery(recordType: "CD_HighScore", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "CD_score", ascending: false)]

        var fetchedScores: [CloudHighScore] = []

        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = limit

        operation.recordMatchedBlock = { recordID, result in
            switch result {
            case .success(let record):
                let player = record["CD_playerName"] as? String ?? "Unknown"
                let score = record["CD_score"] as? Int ?? 0
                let date = record["CD_date"] as? Date

                let entry = CloudHighScore(id: recordID, player: player, score: score, date: date)
                fetchedScores.append(entry)
            case .failure(let error):
                logger.error("Record fetch failed: \(error.localizedDescription)")
            }
        }

        operation.queryResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(.success(fetchedScores))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }

        database.add(operation)
    }
    
    static func isPlayerNameTaken(_ name: String, completion: @escaping (Bool) -> Void) {
        let predicate = NSPredicate(format: "CD_playerName == %@", name)
        let query = CKQuery(recordType: "CD_HighScore", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 1

        var found = false

        operation.recordMatchedBlock = { _, result in
            switch result {
            case .success:
                found = true
            case .failure(let error):
                logger.error("Chyba při hledání jména \(name): \(error.localizedDescription)")
            }
        }

        operation.queryResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(found)
                case .failure(let error):
                    logger.error("Chyba při dotazu na jméno \(name): \(error.localizedDescription)")
                    // Fail-safe: umožní pokračovat, ale zaloguje
                    completion(false)
                }
            }
        }

        database.add(operation)
    }
}
