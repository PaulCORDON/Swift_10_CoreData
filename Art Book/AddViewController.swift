//
//  AddViewController.swift
//  Art Book
//
//  Created by MAC-DIN-002 on 21/05/2019.
//  Copyright © 2019 MAC-DIN-002. All rights reserved.
//

import UIKit
import CoreData
import Photos

class AddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artisteText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    
    var chosenPainting = ""
    
    @IBAction func SaveBtnClicked(_ sender: Any) {
        print("SaveBtnClicked")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        /*forEntityName regarder dans Art_Book.xcdatamodeld*/
        let newArt = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        /*forKey regarder dans Art_Book.xcdatamodeld*/
        newArt.setValue(nameText.text, forKey: "name")
        newArt.setValue(artisteText.text, forKey: "artist")
        if let year =  Int(yearText.text!) {
            newArt.setValue(year, forKey: "year")
        }
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newArt.setValue(data, forKey: "image")

        do{
            try context.save()
            print("art save successfully")
        }
        catch{
            print("error will saving")
        }
        /*on notifie qu'on a ajouter une oeuvre*/
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "paintingCreated"), object: nil)
        /*on revient à la vue pécédente*/
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            fetchRequest.predicate = NSPredicate(format: "name = %@", self.chosenPainting)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey : "name") as? String {
                            nameText.text = name
                        }
                        if let year = result.value(forKey : "year") as? Int {
                            yearText.text = String(year)
                        }
                        if let artist = result.value(forKey : "artist") as? String {
                            artisteText.text = String(artist)
                        }
                        if let imageData = result.value(forKey : "image") as? Data {
                            let image = UIImage(data: imageData)
                            self.imageView.image = image
                        }

                    }
                }
            }catch{
                print("error")
            }
            
        }
        else{
            imageView.image = UIImage(named: "TAPME.jpg")
            nameText.text = ""
            yearText.text = ""
            artisteText.text = ""

        }
        
        checkPermission()
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddViewController.selectImage))
        imageView.addGestureRecognizer(gestureRecognizer)
    }

    @objc func selectImage(){
        //selecting image from library
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker,animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
    }
}
