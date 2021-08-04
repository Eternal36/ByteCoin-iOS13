//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "EC46F92A-0126-4059-B06C-65E8BDE9FB73"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
        
    func getCoinPrice(selectedCurrency: String) {
        let urlString = "\(baseURL)/\(selectedCurrency)?apikey=\(apiKey)"
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let coin = self.parseJSON(safeData) {
                        let priceString = String(format: "%.2f", coin.rate)
                        self.delegate?.didUpdatePrice(price: priceString, currency: selectedCurrency)
                        return
                    }
                }
            }
            task.resume()
        }
    }
    
    
    func parseJSON(_ coinData: Data) -> CoinData? {
        let decoder = JSONDecoder()
        do {
            let decoderData = try decoder.decode(CoinData.self, from: coinData)
            let rate = decoderData.rate
            
            let coinRate = CoinData(rate: rate)
            return coinRate
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
