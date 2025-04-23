//
//  CoinRowView.swift
//  20241215_CryptoAPP
//
//  Created by Yen Lin on 2024/12/16.
//

import SwiftUI

struct CoinRowView: View {
    
    let coin: CoinModel
    var showHoldingsColumn: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            
            leftColumn
            
            Spacer()
            
            if showHoldingsColumn {
                centerColumn
            }
            
            rightColumn

        }.font(.subheadline)
    }
}

#Preview("Light Mode") {
    CoinRowView(coin: DeveloperPreview.instance.coin, showHoldingsColumn: true)
        .previewLayout(.sizeThatFits)
}

#Preview("Dark Mode") {
    CoinRowView(coin: DeveloperPreview.instance.coin, showHoldingsColumn: true)
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
}

extension CoinRowView {
    
    private var leftColumn: some View {
        HStack(spacing: 0) {
            Text("\(coin.rank)")
                .font(.caption)
                .foregroundColor(Color.theme.secondary)
                .frame(minWidth: 30)
            CoinImageView(coin: coin)
                .frame(width: 30, height: 30)
            Text(coin.symbol.uppercased())
                .font(.headline)
                .padding(6)
                .foregroundColor(Color.theme.accent)
        }
    }
    
    private var centerColumn: some View {
        VStack(alignment: .trailing) {
            Text(coin.currentHoldingsValue.asCurrencyWith2Decimals())
                .bold()
            Text((coin.currentHoldings ?? 0).asNumberString())
        }
        .foregroundColor(Color.theme.accent)
    }
    
    private var rightColumn: some View {
        VStack(alignment: .trailing) {
            Text(coin.currentPrice.asCurrencyWith6Decimals())
                .bold()
                .foregroundColor(Color.theme.accent)
            Text(coin.priceChangePercentage24H?.asPercentageString() ?? "")
                .foregroundColor(
                    (coin.priceChangePercentage24H ?? 0 >= 0) ? Color.theme.green:
                        Color.theme.red
                )
        }
        .frame(width: UIScreen.main.bounds.width / 3.5, alignment: .trailing)
    }
}
