//
//  HomeCollectionViewCell.swift
//  Smartally Support
//
//  Created by Uzma Desai on 06/11/17.
//  Copyright © 2017 Bitjini. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class HomeCollectionViewCell: UICollectionViewCell {
    fileprivate var decimalCount: Int = 0
    var delegate: JobViewDelegate?
    //var index = 0
    
    // Class Instances.
    lazy var datePicker: DatePickerView = {
        let view = Bundle.main.loadNibNamed("DatePickerView", owner: nil, options: nil)?.first as! DatePickerView
        view.frame = self.bounds
        view.delegate = self
        return view
    }()
    
    lazy var scroller: ImageScrollView = {
        let scroll = ImageScrollView(frame: CGRect(x: 0, y: 10, width: self.bounds.width, height: 270)) //Constants.height - 260
        scroll.edelegate = self
        return scroll
    }()
    
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldAmount: UITextField!
    @IBOutlet weak var textFieldDate: UITextField!
    @IBOutlet weak var textFieldInvoice: UITextField!
    
    @IBOutlet weak var buttonUpdate: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buttonUpdate.layer.borderColor = UIColor.red.cgColor
    }
    
   
    @IBAction func showDatePicker(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.endEditing(true)
            self.addSubview(self.datePicker)
        }
    }
    
    @IBAction func buttonUpdateAction(_ sender: UIButton) {
        delegate?.updateJob(atIndex: sender.tag)
    }
    
    func set() {
        
        self.addSubview(scroller)
        scroller.imageView.kf.indicatorType = .activity
        //print(tag)
        let job = Job.jobs[tag]
       // print(job)
        // Set image.
        if let url = job.imageEp {
            
            scroller.imageView.kf.setImage(with: url, placeholder: UIImage(named: "jobs_placeholder"))
            // imageView.kf.setImage(with: url, placeholder: UIImage(named: "jobs_placeholder"))
        }
        else { scroller.imageView.image = UIImage(named: "jobs_placeholder") }
        // Other texts.
        
        if job.name == " " { textFieldName.text = "" }else { textFieldName.text = job.name }
        
        if job.amount == " " { textFieldAmount.text = "" } else { textFieldAmount.text = job.amount}
        
        textFieldDate.text = job.date?.mediumStyle() ?? ""
        textFieldInvoice.text = job.invoice
    }
    
}


extension HomeCollectionViewCell: DatePickerDelegate, EndEditingDelegate {
    func selectedDate(_ date: Date) {
        Job.jobs[tag].date = date
        set()
    }
    
    func endEditing() {
        self.endEditing(true)
    }
}

extension HomeCollectionViewCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField.tag {
        case 0:
            textField.autocapitalizationType = .words
            
        case 1:
            decimalCount = 0
            
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let manager = IQKeyboardManager.sharedManager()
        if manager.canGoNext { manager.goNext() }
        else { endEditing(true) }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { delegate?.dropBanner(withString: "Please fill out all fields."); return }
        switch textField.tag {
        case 0:
            if text.isEmpty { delegate?.dropBanner(withString: "Merchant name can't be blank."); break }
            Job.jobs[tag].name = text
            
        case 1:
            let text = textField.text ?? ""
            if text.isEmpty { delegate?.dropBanner(withString: "Amount can't be blank."); break }
            Job.jobs[tag].amount = text.to2DecimalPlaces()
            
        case 2:
            Job.jobs[tag].invoice = text
            
        default:
            break
        }
        set()
    }
    
    // .2 places decimal logic.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 1 {
            if string == "." && (textField.text ?? "").contains(".") { return false }
            if string == "." { return reachedDecimal(range) }
            else if decimalCount > 0 { return afterDecimal(range) }
        }
        
        return true
    }
    
    // Algorithm for %.2f decimal places
    func reachedDecimal(_ range: NSRange) -> Bool {
        decimalCount = range.length == 0 ? decimalCount + 1 : 0
        return true
    }
    
    func afterDecimal(_ range: NSRange) -> Bool {
        if range.length == 0 {
            if decimalCount < 3 {
                decimalCount += 1
                return true
            }
            return false
        }
        decimalCount -= 1
        return true
    }
}


