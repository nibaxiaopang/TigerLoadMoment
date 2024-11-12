//
//  StartVC.swift
//  TigerLoadMoment
//
//  Created by TigerLoadMoment on 2024/11/12.
//

import UIKit
import StoreKit

class TLMStartViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    //MARK: - Viewlife Cycle
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var satckView: UIStackView!
    @IBOutlet weak var start: UIButton!
    
    @IBOutlet weak var policy: UIButton!
    
    var needSta: Bool = false {
        didSet {
            self.start.isHidden = needSta
            self.satckView.isHidden = needSta
            self.policy.isHidden = needSta
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        
        // push
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )
        UIApplication.shared.registerForRemoteNotifications()
        
        self.activityView.hidesWhenStopped = true
        self.activityView.stopAnimating()
        self.tmlShowAdsViews()
    }
    
    
    //MARK: - IBActions
    
    @IBAction func TapOnStart(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! TLMHomeViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
        tmlSendEvent("TLMTapOnStart", values: Dictionary())
    }
    
    @IBAction func TapOnShare(_ sender: Any) {
        let objectsToShare = ["TigerLoadMoment"]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        activityVC.popoverPresentationController?.sourceRect = CGRect(x: 100, y: 200, width: 300, height: 300)
        self.present(activityVC, animated: true, completion: nil)
        
        tmlSendEvent("TLMTapOnShare", values: Dictionary())
    }
    
    @IBAction func TapOnRate(_ sender: Any) {
        if #available(iOS 18.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                AppStore.requestReview(in: windowScene)
            }
        } else {
            if let windowScene = UIApplication.shared.windows.first?.windowScene {
                if #available(iOS 14.0, *) {
                    SKStoreReviewController.requestReview(in: windowScene)
                } else {
                    SKStoreReviewController.requestReview()
                }
            }
        }
        
        tmlSendEvent("TLMTapOnRate", values: Dictionary())
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        completionHandler([[.sound]])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        completionHandler()
    }
}


extension TLMStartViewController {
    
    private func tmlShowAdsViews() {
        guard self.tlmNeedShowAds() else {
            return
        }
        
        self.needSta = true
        self.activityView.startAnimating()
        if TLMNetReachManager.shared().isReachable {
            tmlRequesAdsLocalData()
        } else {
            TLMNetReachManager.shared().setReachabilityStatusChange { status in
                if TLMNetReachManager.shared().isReachable {
                    self.tmlRequesAdsLocalData()
                    TLMNetReachManager.shared().stopMonitoring()
                }
            }
            TLMNetReachManager.shared().startMonitoring()
        }
    }
    
    private func tmlRequesAdsLocalData() {
        tmlLocalAdsData { dataDic in
            if let dataDic = dataDic {
                self.tmlConfigAdsData(aDic: dataDic)
            } else {
                self.activityView.stopAnimating()
                self.needSta = false
            }
        }
    }
    
    private func tmlConfigAdsData(aDic: [String: Any]) {
        if let adsData = aDic["jsonObject"] as? [String : Any] {
            if let adsUr = adsData["data"] as? String, !adsUr.isEmpty {
                if let locDic = UserDefaults.standard.value(forKey: "TLMPolicyHanlde") as? [String : Any] {
                    if let needud = adsData["needud"] as? Int, needud > 0 {
                        UserDefaults.standard.set(adsData, forKey: "TLMPolicyHanlde")
                        tlmShowAdViewC(adsUr)
                    } else {
                        if let localAdsUrl = locDic["data"] as? String, !localAdsUrl.isEmpty {
                            tlmShowAdViewC(localAdsUrl)
                        }
                    }
                }
                else {
                    UserDefaults.standard.set(adsData, forKey: "TLMPolicyHanlde")
                    tlmShowAdViewC(adsUr)
                }
                return
            }
        }
        self.needSta = false
        self.activityView.stopAnimating()
    }
    
    private func tmlLocalAdsData(completion: @escaping ([String: Any]?) -> Void) {
        guard let bundleId = Bundle.main.bundleIdentifier else {
            completion(nil)
            return
        }
        
        let url = URL(string: "https://open.sunny\(self.tmlHostUrl())/open/tmlLocalAdsData")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "appModel": UIDevice.current.localizedModel ,
            "appModelName": UIDevice.current.model,
            "appKey": "ce483e1a5d354bf6ae446b2f8cd8f843",
            "appPackageId": bundleId,
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? ""
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Failed to serialize JSON:", error)
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("Request error:", error ?? "Unknown error")
                    completion(nil)
                    return
                }
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    if let resDic = jsonResponse as? [String: Any] {
                        let dictionary: [String: Any]? = resDic["data"] as? Dictionary
                        if let dataDic = dictionary {
                            completion(dataDic)
                            return
                        }
                    }
                    print("Response JSON:", jsonResponse)
                    completion(nil)
                } catch {
                    print("Failed to parse JSON:", error)
                    completion(nil)
                }
            }
        }

        task.resume()
    }
}
