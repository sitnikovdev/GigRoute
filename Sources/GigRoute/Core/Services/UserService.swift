import Foundation

protocol UserService {
    func fetchCurrentUser() async -> Result<User, NetworkError>
}

/// Stand-in until a real backend/auth flow exists. Returns a fixed user so
/// Home/Profile can be built and tested end to end. Swap for a
/// `NetworkService`-backed implementation once the API is available —
/// nothing outside this file needs to change, since callers only see
/// `UserService`.
final class LocalUserService: UserService {
    private let user: User

    init(user: User = User(id: "local-1", name: "Олег")) {
        self.user = user
    }

    func fetchCurrentUser() async -> Result<User, NetworkError> {
        .success(user)
    }
}
