//
//  ViewController.swift
//  JGCBiometricExample
//
//  Created from JGC Templates on 17/3/18.
// Copyright © 2018 Javier Garcia Castro. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var biometricButton: UIButton!
    @IBOutlet weak var loginButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginButtonWidthConstraint: NSLayoutConstraint!
    var bioAuthenticationType: JGCAuthenticationType?
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.authenticationCompletionHandler(loginStatusNotification:)), name: .JGCBiometricAuthenticationLoginStatus, object: nil)

        initialize()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func initialize() {
        
//        self.navigationController?.navigationBar.backgroundColor = .red
        title = "Login"
        
        loginButton.setTitle("Login!!", for: .normal)
        loginButton.backgroundColor = .white
        loginButton.setTitleColor(.black, for: .normal)
        
        loginButtonHeightConstraint.constant = 60.0
        loginButtonWidthConstraint.constant = 200.0
        
        loginButton.layer.shadowColor = UIColor.black.cgColor
        loginButton.layer.shadowOpacity = 0.5
        loginButton.layer.shadowOffset = CGSize.init(width: -2, height: 2)
        loginButton.layer.cornerRadius = loginButtonHeightConstraint.constant / 2
        loginButton.layer.borderWidth = 1.0
        
        bioAuthenticationType = JGCBiometricAuthentication().getBiometricAuthenticationType()
        
        if bioAuthenticationType == JGCAuthenticationType.JGCFaceID {
            biometricButton.setImage(UIImage(named: "faceID_icon"), for: .normal)
        } else if bioAuthenticationType == JGCAuthenticationType.JCGTouchID {
            biometricButton.setImage(UIImage(named: "touchID_icon"), for: .normal)
        } else {
            biometricButton.isHidden = true
            biometricButton.isEnabled = false
        }
    }
    
    // MARK: - Private Methods
    
    func authenticateWithBiometric() {
        let bioAuth = JGCBiometricAuthentication()
        bioAuth.reasonString = "To login into the app"
        bioAuth.authenticationWithBiometricID()
    }
    
    @objc func authenticationCompletionHandler(loginStatusNotification: Notification) {
        if let _ = loginStatusNotification.object as? JGCBiometricAuthentication, let userInfo = loginStatusNotification.userInfo {
            if let authStatus = userInfo[JGCBiometricAuthentication.status] as? JGCBiometricAuthenticationStatus {
                if authStatus.success {
                    print("Login Success")
                    DispatchQueue.main.async {
                        self.onLoginSuccess()
                    }
                } else {
                    if let errorCode = authStatus.errorCode {
                        print("Login Fail with code \(String(describing: errorCode)) reason \(authStatus.errorMessage)")
                        DispatchQueue.main.async {
                            self.onLoginFail()
                        }
                    }
                }
            }
        }
    }
    
    func onLoginSuccess() {
        let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let homeVC = mainStoryboard.instantiateViewController(withIdentifier: "HomeViewControllerIdentifier")
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    
    func onLoginFail() {
        let alert = UIAlertController(title: "Login", message: "Login Failed", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - User Actions
    
    @IBAction func userDidTapLoginButton(_ sender: Any) {
        if bioAuthenticationType == JGCAuthenticationType.JGCFaceID {
            print("JGCFaceID")
            authenticateWithBiometric()

        } else if bioAuthenticationType == JGCAuthenticationType.JCGTouchID {
            print("JGCTouchID")
            authenticateWithBiometric()
        }
    }

    @IBAction func userDidTouchDownLoginButton(_ sender: Any) {
        loginButton.layer.shadowOpacity = 0
        loginButton.layer.shadowOffset = CGSize.zero
    }
    
    @IBAction func userDidTouchUpLoginButton(_ sender: Any) {
        loginButton.layer.shadowOpacity = 0.5
        loginButton.layer.shadowOffset = CGSize.init(width: -2, height: 2)
        
        let alertController = UIAlertController(title: "Authentication Required", message: "Please, enter your userID and pass", preferredStyle: .alert)
        weak var usernameTextField: UITextField!
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "User ID"
            usernameTextField = textField
        })
        weak var passwordTextField: UITextField!
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
            passwordTextField = textField
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Log In", style: .destructive, handler: { action in
            print(usernameTextField.text! + "\n" + passwordTextField.text!)
            let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
            let homeVC = mainStoryboard.instantiateViewController(withIdentifier: "HomeViewControllerIdentifier")
            self.navigationController?.pushViewController(homeVC, animated: true)
        }))
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }

}

