//
//  HomeVC.swift
//  TigerLoadMoment
//
//  Created by TigerLoadMoment on 2024/11/12.
//

import UIKit

class TLMHomeViewController: UIViewController {
    
    //MARK: - Viewlife Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - IBActions
    
    @IBAction func TapOnTotalUnitStress(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TotalVC") as! TLMTotalViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func TapOnDeflection(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeflectionVC") as! TLMDeflectionViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func TapOnStress(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "StressVC") as! TLMStressViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func TapOnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func TapOnMoment(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TransverseVC") as! TLMTransverseViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
