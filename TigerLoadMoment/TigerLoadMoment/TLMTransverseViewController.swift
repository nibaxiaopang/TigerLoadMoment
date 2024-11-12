//
//  TransverseVC.swift
//  TigerLoadMoment
//
//  Created by TigerLoadMoment on 2024/11/12.
//

import UIKit

class TLMTransverseViewController: UIViewController {
    
    @IBOutlet weak var txtClearDistanceBetweenFlangesInInch: UITextField!
    @IBOutlet weak var txtActualStiffenerSpacingInInch: UITextField!
    @IBOutlet weak var txtWebThicknessInInch: UITextField!
    @IBOutlet weak var viewResult: UIView!
    @IBOutlet weak var lblResult: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        viewResult.isHidden = true
    }
    
    @IBAction func TapOnCalculate(_ sender: Any) {
        guard let clearDistanceText = txtClearDistanceBetweenFlangesInInch.text,
              let stiffenerSpacingText = txtActualStiffenerSpacingInInch.text,
              let webThicknessText = txtWebThicknessInInch.text,
              let clearDistance = Double(clearDistanceText),
              let webThickness = Double(webThicknessText) else {
            lblResult.text = "Invalid input"
            viewResult.isHidden = false
            return
        }
        
        let momentOfInertia = (webThickness * pow(clearDistance, 3)) / 12
        lblResult.text = String(format: "Moment of Inertia: %.2f in^4", momentOfInertia)
        viewResult.isHidden = false
    }
    
    @IBAction func TapOnClear(_ sender: Any) {
        txtClearDistanceBetweenFlangesInInch.text = ""
        txtActualStiffenerSpacingInInch.text = ""
        txtWebThicknessInInch.text = ""
        lblResult.text = ""
        viewResult.isHidden = true
    }
    
    @IBAction func TapOnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func TapOnFormula(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TransFormulaVC") as! TLMTransFormulaViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
