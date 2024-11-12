//
//  StressVC.swift
//  TigerLoadMoment
//
//  Created by TigerLoadMoment on 2024/11/12.
//

import UIKit

class TLMStressViewController: UIViewController {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var txtLoadInNewton: UITextField!
    @IBOutlet weak var txtEccentricityInMeter: UITextField!
    @IBOutlet weak var txtCrossSectionalAreaInSquareMeter: UITextField!
    @IBOutlet weak var txtMomentOfInertiaInMeter: UITextField!
    @IBOutlet weak var txtLengthOfBeamInMeter: UITextField!
    @IBOutlet weak var txtYoungModulusInPascal: UITextField!
    @IBOutlet weak var viewResult: UIView!
    @IBOutlet weak var lblResult: UILabel!
    
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
        guard let loadText = txtLoadInNewton.text, let load = Double(loadText),
              let eccentricityText = txtEccentricityInMeter.text, let eccentricity = Double(eccentricityText),
              let areaText = txtCrossSectionalAreaInSquareMeter.text, let area = Double(areaText),
              let inertiaText = txtMomentOfInertiaInMeter.text, let inertia = Double(inertiaText) else {
            let alert = UIAlertController(title: "Error", message: "Please enter valid numbers in all fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let axialStress = load / area
        
        let moment = load * eccentricity
        
        if let lengthText = txtLengthOfBeamInMeter.text, let length = Double(lengthText) {
            let y = length / 2
            
            let bendingStress = moment * y / inertia
            
            let totalStress = axialStress + bendingStress
            
            lblResult.text = String(format: "Total Stress: %.4f Pascals", totalStress)
            viewResult.isHidden = false
        }
    }
    
    @IBAction func TapOnClear(_ sender: Any) {
        viewResult.isHidden = true
        txtLoadInNewton.text = ""
        txtEccentricityInMeter.text = ""
        txtCrossSectionalAreaInSquareMeter.text = ""
        txtMomentOfInertiaInMeter.text = ""
        txtLengthOfBeamInMeter.text = ""
        txtYoungModulusInPascal.text = ""
        lblResult.text = ""
    }
    
    @IBAction func TapOnFormula(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "StressFormulaVC") as! TLMStressFormulaViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
