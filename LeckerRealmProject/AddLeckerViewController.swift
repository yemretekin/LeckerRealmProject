    //
    //  AddLeckerViewController.swift
    //  LeckerRealmProject
    //
    //  Created by Emre Tekin on 16.06.2023.
    //

    import UIKit

    protocol AddLeckerViewControllerDelegate: AnyObject {
        func didAddNewFlower()
    }

    class AddLeckerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        @IBOutlet weak var leckerImage: UIImageView!
        @IBOutlet weak var leckerName: UITextField!
        
        weak var delegate: AddLeckerViewControllerDelegate?

        override func viewDidLoad() {
            super.viewDidLoad()

            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            leckerImage.isUserInteractionEnabled = true
            leckerImage.addGestureRecognizer(tap)
            
            let tap1 = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
            view.addGestureRecognizer(tap1)
        }
        
        @objc func handleTap() {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            
            present(picker, animated: true)
        }
        
        
        @objc func hideKeyboard() {
            view.endEditing(true)
        }


        
        @IBAction func saveButtonTapped(_ sender: Any) {
            
            
            if let flowerName = leckerName.text, let flowerImage = leckerImage.image {
                if let imageData = flowerImage.pngData() {
                    let filename = UUID().uuidString + ".png"
                    let imagePath = getDocumentsDirectory().appendingPathComponent(filename)
                    do {
                        try imageData.write(to: imagePath)
                        
                        let realFlower = RealFlower()
                        realFlower.id = UUID()
                        realFlower.firstName = flowerName
                        realFlower.imagePath = filename
                        
                        DatabaseHelper.shared.saveFlowers(rFlower: realFlower)
                        if let savedImage = UIImage(contentsOfFile: imagePath.path) {
                            self.leckerImage.image = savedImage
                        }
                        
                        delegate?.didAddNewFlower()
                        print("Eklendi")
                    } catch {
                        print("Failed to save image: \(error.localizedDescription)")
                    }
                }
            }

            navigationController?.popViewController(animated:true)
            
        }
        
        

        
        func getDocumentsDirectory() -> URL {
            
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            self.leckerImage.image = info[.editedImage] as? UIImage
            dismiss(animated: true)
        }
        
        
    }
