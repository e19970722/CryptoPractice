//
//  HomeViewModel.swift
//  20241215_CryptoAPP
//
//  Created by Yen Lin on 2024/12/17.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    
    @Published var statistics: [StatisticModel] = []
    
    @Published var allCoins: [CoinModel] = []
    @Published var portfolioCoins: [CoinModel] = []
    @Published var searchText: String = ""
    
    private let coinDataService = CoinDataService()
    private let marketDataService = MarketDataService()
    private let portfolioDataService = PortfolioDataService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    func addSubscribers() {

        // update allCoins
        $searchText
            .combineLatest(coinDataService.$allCoins)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterCoins)
            .sink { [weak self] returnedCoins in
                self?.allCoins = returnedCoins
            }
            .store(in: &cancellables)
        
        marketDataService.$marketData
            .map (mapGlobalMarketData)
            .sink { [weak self] (returnedStats) in
                self?.statistics = returnedStats
            }
            .store(in: &cancellables)
        
        // update Portoflio
        $allCoins
            .combineLatest(portfolioDataService.$saveEntities)
            .map { (coinModels, portfolioEntities) -> [CoinModel] in
                coinModels.compactMap { (coin) -> CoinModel? in
                    guard let entity = portfolioEntities.first(where: { $0.coinID == coin.id }) else {
                        return nil
                    }
                    return coin.updateHoldings(amount: entity.amount)
                }
            }.sink { (returnedCoin) in
                self.portfolioCoins = returnedCoin
            }
            .store(in: &cancellables)
    }
    
    func updatePortfolio(coin: CoinModel, amount: Double) {
        portfolioDataService.updatePortfolio(coin: coin, amount: amount)
    }
    
    func filterCoins(text: String, coins: [CoinModel]) -> [CoinModel] {
        guard !text.isEmpty else {
            return coins
        }
        
        let lowercasedText = text.lowercased()
        
        return coins.filter { coin in
            return coin.name.lowercased().contains(lowercasedText) ||
                coin.id.lowercased().contains(lowercasedText) ||
                coin.symbol.lowercased().contains(lowercasedText)
        }
    }
    
    func mapGlobalMarketData(marketDataModel: MarketDataModel?) -> [StatisticModel] {
        var stats: [StatisticModel] = []
        
        guard let data = marketDataModel else {
            return stats
        }
        
        let marketCap = StatisticModel(title: "Market Cap", value: data.marketCap, percentageChange: data.marketCapChangePercentage24HUsd)
        let volume = StatisticModel(title: "Volume", value: data.volume)
        let btcDominance = StatisticModel(title: "BTC Dominance", value: data.btcDominance)
        let portfolio = StatisticModel(title: "Portfolio Value", value: "$0.00", percentageChange: 0)
        
        stats.append(contentsOf: [
            marketCap,
            volume,
            btcDominance,
            portfolio
        ])
        return stats
    }
}
