//
//  TotalVC.swift
//  TigerLoadMoment
//
//  Created by TigerLoadMoment on 2024/11/12.
//

import UIKit

class TLMTotalViewController: UIViewController {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var txtAxialLoadInLb: UITextField!
    @IBOutlet weak var txtCrossSectionalAreaInSquareInch: UITextField!
    @IBOutlet weak var txtDistanceOfTheLoadFromTheCentroidalAxisInInch: UITextField!
    @IBOutlet weak var txtDistanceFromNeutralAxisToOutermostFiberAtTheSectionWhereMaximumMomentOccursInInch: UITextField!
    @IBOutlet weak var txtMomentOfInertiaAboutNeutralAxisAtThatSectionInInch: UITextField!
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
        
        guard let axialLoadText = txtAxialLoadInLb.text, let axialLoad = Double(axialLoadText),
              let crossSectionalAreaText = txtCrossSectionalAreaInSquareInch.text, let crossSectionalArea = Double(crossSectionalAreaText),
              let eccentricityText = txtDistanceOfTheLoadFromTheCentroidalAxisInInch.text, let eccentricity = Double(eccentricityText),
              let yText = txtDistanceFromNeutralAxisToOutermostFiberAtTheSectionWhereMaximumMomentOccursInInch.text, let y = Double(yText),
              let momentOfInertiaText = txtMomentOfInertiaAboutNeutralAxisAtThatSectionInInch.text, let momentOfInertia = Double(momentOfInertiaText) else {
            let alert = UIAlertController(title: "Error", message: "Please enter valid numbers in all fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let axialStress = axialLoad / crossSectionalArea
        
        let moment = axialLoad * eccentricity
        
        let bendingStress = moment * y / momentOfInertia
        
        let totalStress = axialStress + bendingStress
        
        lblResult.text = String(format: "Total Stress: %.2f psi", totalStress)
        viewResult.isHidden = false
    }
    
    @IBAction func TapOnClear(_ sender: Any) {
        viewResult.isHidden = true
        txtAxialLoadInLb.text = ""
        txtCrossSectionalAreaInSquareInch.text = ""
        txtDistanceOfTheLoadFromTheCentroidalAxisInInch.text = ""
        txtDistanceFromNeutralAxisToOutermostFiberAtTheSectionWhereMaximumMomentOccursInInch.text = ""
        txtMomentOfInertiaAboutNeutralAxisAtThatSectionInInch.text = ""
        lblResult.text = ""
    }
    
    
    @IBAction func TapOnFormula(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TotalFormulaVC") as! TLMTotalFormulaViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
