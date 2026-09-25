//
//  BannerView.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-10-18.
//

import SwiftUI
import GoogleMobileAds

struct BannerView: UIViewControllerRepresentable {
    
    let bannerView = GoogleMobileAds.BannerView(adSize: AdSizeBanner)
    
    func makeUIViewController(context: Context) -> UIViewController {
        
        let viewController = UIViewController()
        bannerView.adUnitID = ""//ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = viewController
        viewController.view.addSubview(bannerView)
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
        bannerView.load(Request())
    }
}

#Preview {
    BannerView()
                .frame(width: AdSizeBanner.size.width,
                       height: AdSizeBanner.size.height)
}
