import Fluent

// 1
struct CreateUserMigration: Migration {
    // 2
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        // 3
        database.schema("users")
            // 4
            .id()
            // 5
            .field("name", .string, .required)
            .field("username", .string, .required)
            // 6
            .create()
    }

    // 7
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users").delete()
    }
}
