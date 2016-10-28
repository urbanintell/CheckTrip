//
//  RegisterViewController.swift
//  FriendlyChatSwift
//
//  Created by kromah on 6/12/16.
//  
//

import UIKit
import Firebase



class RegisterViewController: UIViewController {
    
    
   
   
    @IBOutlet var spinner: UIActivityIndicatorView!
 
    
    @IBOutlet weak var nameFeild: UITextField!
    
    
    @IBOutlet weak var emailFeild: UITextField!
    
    @IBOutlet weak var passwordFeild: UITextField!
    
    
    @IBOutlet weak var confirmPasswordFeild:
    
    UITextField!
    var completionDialog: UIAlertController!
    var ref: FIRDatabaseReference!
    var newuser: [String:String] = [:]
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = UIColor.checkTripBlue()
        spinner.hidesWhenStopped = true
        spinner.center = view.center
        
        
        view.addSubview(spinner)
        configureDatabase() 
        // Do any additional setup after loading the view.
        
        passwordFeild.isSecureTextEntry  = true
        confirmPasswordFeild.isSecureTextEntry  = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapSignUp(_ sender: AnyObject) {
        
        let email = emailFeild.text
        let password = passwordFeild.text
        
        var alert =  UIAlertController(title: "Invalid Email", message: "", preferredStyle: .alert)
        
        let issue =  UIAlertController(title: "Error", message: "", preferredStyle: .alert)
        
        let done = UIAlertAction(title: "Done", style: .default, handler: { (action) in
            print("Clicked")
        })
        

        
        alert.addAction(done)
        issue.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            self.dismiss(animated: false, completion: nil);
        })
        )
        
        if email!.isEmpty || password!.isEmpty {
         
            present(alert, animated:true){}
            return
        }
        
        else if  (password?.characters.count)! < 5 {
            alert  =  UIAlertController(title: "Invalid Password", message: "Password must have at least 5 characters", preferredStyle: .alert)
            alert.addAction(done)
            present(alert, animated: true){}
        }else{
            spinner.startAnimating()
            FIRAuth.auth()?.createUser(withEmail: email!, password: password!) { (user, error) in

                
                
                if let error = error {
                    issue.title = error.localizedDescription
                    issue.addAction(done)
                    self.present(issue,animated:true,completion:nil)
               
                    return
                }
        
                guard let name =  self.nameFeild.text, let email = self.emailFeild.text else {
                    print("Name is null")
                    return
                }
                
                self.newuser[Constants.UserFields.name] = name;
                self.newuser[Constants.UserFields.email] = email
                self.newuser[Constants.UserFields.uid] = user!.uid
                
                self.registerUser(self.newuser)
                
            }
            
        }
    
    }
    
    func registerUser(_ data: [String: String]) {
        
        
        print(data)
        // Push data to Firebase Database
        
        self.ref.child("users/"+data[Constants.UserFields.uid]!).setValue(data)
        
        self.spinner.stopAnimating()
        
//        Successfully created
        let success =  UIAlertController(title: "Successfully Created", message: "", preferredStyle: .alert)
        success.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            self.dismiss(animated: false, completion: nil);
        }))
        
        self.present(success, animated: true, completion: nil)
    }

    func configureDatabase(){
        
    self.ref = FIRDatabase.database().reference()
    }
    
 
    
    
    
    
    //    Gets rid of keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    

    
    func signedIn(_ user: FIRUser?) {
       
        
        
        AppState.sharedInstance.displayName = "\(newuser[Constants.UserFields.name]!)"
        AppState.sharedInstance.photoUrl = user?.photoURL
        AppState.sharedInstance.signedIn = true
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationKeys.SignedIn), object: nil)
        
    }

}

extension UIColor{
    
    class func checkTripBlue() -> UIColor{
        
        return  UIColor(red:60/255,green:117/255,blue:255/255,alpha:1)
    }
}

