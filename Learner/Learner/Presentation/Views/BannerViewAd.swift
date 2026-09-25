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
      let adSize: AdSize

      init(_ adSize: AdSize) {
        self.adSize = adSize
      }

      func makeUIView(context: Context) -> UIView {
        // Wrap the Google Mobile Ads banner in a UIView. The banner automatically reloads a new ad when its
        // frame size changes; wrapping it insulates the banner from size
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
      @MainActor
      final class BannerCoordinator: NSObject, GoogleMobileAds.BannerViewDelegate {

        private(set) lazy var bannerView: GoogleMobileAds.BannerView = {
          let banner = GoogleMobileAds.BannerView(adSize: parent.adSize)
          // [START load_ad]
          banner.adUnitID = ""// "ca-app-pub-3940256099942544/2435281174"
          banner.load(Request())
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

        func bannerViewDidReceiveAd(_ bannerView: GoogleMobileAds.BannerView) {
          print("DID RECEIVE AD.")
        }

        func bannerView(_ bannerView: GoogleMobileAds.BannerView, didFailToReceiveAdWithError error: Error) {
          print("FAILED TO RECEIVE AD: \(error.localizedDescription)")
        }
      }
    }
