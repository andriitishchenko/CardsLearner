//
//  BannerViewAd.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-10-18.
//
import GoogleMobileAds
import SwiftUI

// https://github.com/googleads/googleads-mobile-ios-examples/blob/69fb7c66637e935dc07a08e6bc8cc2ed1a5dc468/Swift/advanced/SwiftUIDemo/SwiftUIDemo/Banner/BannerContentView.swift#L30-L52

    struct BannerViewAd: UIViewRepresentable {
      let adSize: GADAdSize

      init(_ adSize: GADAdSize) {
        self.adSize = adSize
      }

      func makeUIView(context: Context) -> UIView {
        // Wrap the GADBannerView in a UIView. GADBannerView automatically reloads a new ad when its
        // frame size changes; wrapping in a UIView container insulates the GADBannerView from size
        // changes that impact the view returned from makeUIView.
        let view = UIView()
        view.addSubview(context.coordinator.bannerView)
        return view
      }

      func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.bannerView.adSize = adSize
      }

      func makeCoordinator() -> BannerCoordinator {
        return BannerCoordinator(self)
      }
      // [END create_banner_view]

      // [START create_banner]
      class BannerCoordinator: NSObject, GADBannerViewDelegate {

        private(set) lazy var bannerView: GADBannerView = {
          let banner = GADBannerView(adSize: parent.adSize)
          // [START load_ad]
          banner.adUnitID = ""// "ca-app-pub-3940256099942544/2435281174"
          banner.load(GADRequest())
          // [END load_ad]
          // [START set_delegate]
          banner.delegate = self
          // [END set_delegate]
          return banner
        }()

        let parent: BannerViewAd

        init(_ parent: BannerViewAd) {
          self.parent = parent
        }
        // [END create_banner]

        // MARK: - GADBannerViewDelegate methods

        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
          print("DID RECEIVE AD.")
        }

        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
          print("FAILED TO RECEIVE AD: \(error.localizedDescription)")
        }
      }
    }
