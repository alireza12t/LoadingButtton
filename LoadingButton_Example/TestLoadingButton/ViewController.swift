//
//  ViewController.swift
//  TestLoadingButton
//
//  Created by Alireza on 1/7/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var loadingButton: LoadingButton!
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBAction func ChangeTextButtonDidTap(_ sender: Any) {
        var loadingText = titleTextField.text ?? ""
        if loadingText.isEmpty {
            loadingText = "Loading..."
        }
        loadingButton.loadingText = loadingText
    }
    
    @IBAction func loadingButtonDidTap(_ sender: Any) {
        loadingButton.isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.loadingButton.isAnimating = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

