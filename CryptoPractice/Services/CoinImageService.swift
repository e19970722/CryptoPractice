//
//  CoinImageService.swift
//  20241215_CryptoAPP
//
//  Created by Yen Lin on 2025/1/4.
//

import Foundation
import SwiftUI
import Combine

class CoinImageService {
    
    @Published var image: UIImage? = nil
    private var imageSubscription: AnyCancellable?
    private let coin: CoinModel
    private let fileManager = LocalFileManager.instance
    private let folderName = "coin_image"
    private let imageName: String
    
    init(coin: CoinModel) {
        self.coin = coin
        self.imageName = coin.id
        getCoinImage()
    }
    
    private func getCoinImage() {
        if let savedImage = self.fileManager.getImage(imageName: imageName, folderName: folderName) {
            self.image = savedImage
//            print("Retrieved image from File Manager.")
        } else {
            downloadCoinImage()
//            print("Downloading image now.")
        }
    }
    
    private func downloadCoinImage() {
        guard let url = URL(string: coin.image) else { return }
        
        imageSubscription = NetworkingManager.download(url: url)
            .tryMap({ (data) -> UIImage? in
                return UIImage(data: data)
            })
            .sink(receiveCompletion: NetworkingManager.handleCompletion,
                  receiveValue: { [weak self] returnedImage in
                guard let self = self,
                      let downloadedImage = returnedImage
                else { return }
                self.image = downloadedImage
                self.imageSubscription?.cancel()
                self.fileManager.saveImage(image: downloadedImage, imageName: imageName, folderName: folderName)
            })
    }
}
