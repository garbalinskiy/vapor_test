import Fluent
import Vapor

struct AcronymsController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let acronymsRoutes = routes.grouped("api", "acronyms")

        acronymsRoutes.get(use: getAllHandler)
        // 1
        acronymsRoutes.post(use: createHandler)
        // 2
        acronymsRoutes.get(":acronymID", use: getHandler)
        // 3
        acronymsRoutes.put(":acronymID", use: updateHandler)
        // 4
        acronymsRoutes.delete(":acronymID", use: deleteHandler)
        // 5
        acronymsRoutes.get("search", use: searchHandler)
        // 6
        acronymsRoutes.get("first", use: getFirstHandler)
        // 7
        acronymsRoutes.get("sorted", use: sortedHandler)
        
        acronymsRoutes.get(":acronymID", "user", use: getUserHandler)
    }

    func getAllHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
        Acronym.query(on: req.db).all()
    }

    func createHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let requestContent = try req.content.decode(AcronymsCreateRequest.self)
        let acronym = Acronym(
            short: requestContent.short,
            long: requestContent.long,
            userID: requestContent.userID
        )
        return acronym.save(on: req.db).map { acronym }
    }

    func getHandler(_ req: Request)
        -> EventLoopFuture<Acronym>
    {
        Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func updateHandler(_ req: Request) throws
        -> EventLoopFuture<Acronym>
    {
        let updatedAcronym = try req.content.decode(Acronym.self)
        return Acronym.find(
            req.parameters.get("acronymID"),
            on: req.db
        )
        .unwrap(or: Abort(.notFound)).flatMap { acronym in
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            return acronym.save(on: req.db).map {
                acronym
            }
        }
    }

    func deleteHandler(_ req: Request)
        -> EventLoopFuture<HTTPStatus>
    {
        Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }

    func searchHandler(_ req: Request) throws
        -> EventLoopFuture<[Acronym]>
    {
        guard let searchTerm = req
            .query[String.self, at: "term"]
        else {
            throw Abort(.badRequest)
        }

        return Acronym.query(on: req.db).group(.or) { or in
            or.filter(\.$short == searchTerm)
            or.filter(\.$long == searchTerm)
        }.all()
    }

    func getFirstHandler(_ req: Request)
        -> EventLoopFuture<Acronym>
    {
        return Acronym.query(on: req.db)
            .first()
            .unwrap(or: Abort(.notFound))
    }

    func sortedHandler(_ req: Request)
        -> EventLoopFuture<[Acronym]>
    {
        return Acronym.query(on: req.db)
            .sort(\.$short, .ascending).all()
    }

    // 1
    func getUserHandler(_ req: Request) -> EventLoopFuture<User> {
        // 2
        Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                // 3
                acronym.$user.get(on: req.db)
            }
    }
}
