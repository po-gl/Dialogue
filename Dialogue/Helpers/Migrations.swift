import Foundation

struct Migrations {
    static func performModelMigrationGPT4oIfNeeded() {
        let hasPerformedMigration = UserDefaults.standard.bool(forKey: "hasPerformedModelMigrationGPT4o")
        if !hasPerformedMigration {
            UserDefaults.standard.set(GPTModel.gpt4o.rawValue, forKey: "gptModel")
            UserDefaults.standard.set(true, forKey: "hasPerformedModelMigrationGPT4o")
        }
    }
}
