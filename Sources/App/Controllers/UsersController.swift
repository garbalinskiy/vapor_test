import Vapor

// 1
struct UsersController: RouteCollection
{
    // 2
    func boot(routes: RoutesBuilder) throws
    {
        let usersRoute = routes.grouped("api", "users")
        usersRoute.post(use: createHandler)
        usersRoute.get(use: getAllHandler)
        usersRoute.get(":userID", use: getHandler)
        usersRoute.get(":userID", "acronyms", use: getAcronymsHandler)
    }

    // 5
    func createHandler(_ req: Request)
        throws -> EventLoopFuture<User>
    {
        // 6
        let user = try req.content.decode(User.self)
        // 7
        return user.save(on: req.db).map { user }
    }

    // 1
    func getAllHandler(_ req: Request)
        -> EventLoopFuture<[User]>
    {
        // 2
        User.query(on: req.db).all()
    }

    // 3
    func getHandler(_ req: Request)
        -> EventLoopFuture<User>
    {
        // 4
        User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    // 1
    func getAcronymsHandler(_ req: Request)
        -> EventLoopFuture<[Acronym]>
    {
        // 2
        User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap
            { user in
                // 3
                user.$acronyms.get(on: req.db)
            }
    }
}
