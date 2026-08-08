import Foundation

protocol WalletService {
  func fetchWallet() async -> Result<Wallet, Error>
}

final class LocalWalletService: WalletService {

    func fetchWallet() async -> Result<Wallet, Error> {
        .success(
            Wallet(
                balance: 15450,
                bonusPoints: 150
            )
        )
    }
}
