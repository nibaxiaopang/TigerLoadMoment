//
//  DeflectionVC.swift
//  TigerLoadMoment
//
//  Created by TigerLoadMoment on 2024/11/12.
//

import UIKit

class TLMDeflectionViewController: UIViewController {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var txtCrossSectionalAreaInSquareInch: UITextField!
    @IBOutlet weak var txtCriticalBucklingLoadInLb: UITextField!
    @IBOutlet weak var txtDistanceOfTheLoadFromTheCentroidalAxisInInch: UITextField!
    @IBOutlet weak var viewResult: UIView!
    @IBOutlet weak var lblResult: UILabel!
    @IBOutlet weak var txtYoungsModulusInPsi: UITextField!
    @IBOutlet weak var txtMomentOfInertiaInInch: UITextField!
    
    //MARK: - Viewlife Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        viewResult.isHidden = true
    }
    
    //MARK: - IBActions
    
    @IBAction func TapOnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func TapOnCalculate(_ sender: Any) {
        
        guard let loadText = txtCriticalBucklingLoadInLb.text, let load = Double(loadText),
              let eccentricityText = txtDistanceOfTheLoadFromTheCentroidalAxisInInch.text, let eccentricity = Double(eccentricityText),
              let modulusText = txtYoungsModulusInPsi.text, let modulus = Double(modulusText),
              let momentOfInertiaText = txtMomentOfInertiaInInch.text, let momentOfInertia = Double(momentOfInertiaText) else {
            let alert = UIAlertController(title: "Error", message: "Please enter valid numbers in all fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let deflection = (load * eccentricity) / (modulus * momentOfInertia)
        
        lblResult.text = String(format: "Deflection: %.4f inches", deflection)
        viewResult.isHidden = false
    }
    
    @IBAction func TapOnClear(_ sender: Any) {
        viewResult.isHidden = true
        txtCrossSectionalAreaInSquareInch.text = ""
        txtCriticalBucklingLoadInLb.text = ""
        txtDistanceOfTheLoadFromTheCentroidalAxisInInch.text = ""
        txtYoungsModulusInPsi.text = ""
        txtMomentOfInertiaInInch.text = ""
        lblResult.text = ""
    }
    
    @IBAction func TapOnFormula(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DeflectionFormulaVC") as! TLMDeflectionFormulaViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
