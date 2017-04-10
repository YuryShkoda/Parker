/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func loginOrRegister(_ sender: Any) {
        
        let username = usernameTextField.text
        let password = passwordTextField.text
        
        if username != "" && password != "" {
        
            PFUser.logInWithUsername(inBackground: username!, password: password!, block: { (success, error) in
                
                if error != nil {
                    
                    let user = PFUser()
                    
                    user.username = username
                    user.password = password
                    
                    user.signUpInBackground(block: { (success, error) in
                        
                        if let error = error as? NSError {
                        
                            var errorMessage = "Signup faild - please try again later."
                            
                            if let errorString = error.userInfo["error"] as? String{
                            
                                errorMessage = errorString
                            
                            }
                            
                            self.errorLabel.text = errorMessage
                        
                        } else {
                        
                            print("Signed up!")
                            
                            self.performSegue(withIdentifier: "showSpotsList", sender: self)
                        
                        }
                        
                    })
                    
                
                } else {
                
                    print("Logged in")
                    
                    self.performSegue(withIdentifier: "showSpotsList", sender: self)
                    
                }
                
            })
        
        } else {
        
            errorLabel.text = "Username and Password are required."
        
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
