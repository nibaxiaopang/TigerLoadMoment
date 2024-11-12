//
//  DeflectionFormulaVC.swift
//  TigerLoadMoment
//
//  Created by TigerLoadMoment on 2024/11/12.
//

import UIKit

class TLMDeflectionFormulaViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = true
    }
    

    @IBAction func TapOnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
