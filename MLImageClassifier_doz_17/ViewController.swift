//
//  ViewController.swift
//  MLImageClassifier_doz_17
//
//  Created by Alexander Hoch on 29.01.21.
//  Copyright © 2021 zancor. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    
    @IBOutlet weak var imageView: UIImageView!
       @IBOutlet weak var cameraButton: UIBarButtonItem!
       @IBOutlet weak var classificationLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        cameraButton.target = self
        cameraButton.action = #selector(btndown)
    }

    //====================-GET PICTURE FORM CAMERA OR LIBRARYFILE-=======================
            @objc func btndown(){
                takePicture()
            }
            
            func takePicture() {
                // Show options for the source picker only if the camera is available.
                guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                    presentPhotoPicker(sourceType: .photoLibrary)
                    return
                }
                
                let photoSourcePicker = UIAlertController()
                let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { [unowned self] _ in
                    self.presentPhotoPicker(sourceType: .camera)
                }
                let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { [unowned self] _ in
                    self.presentPhotoPicker(sourceType: .photoLibrary)
                }
                
                photoSourcePicker.addAction(takePhoto)
                photoSourcePicker.addAction(choosePhoto)
                photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                present(photoSourcePicker, animated: true)
            }
            
            func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = sourceType
                present(picker, animated: true)
            }
    
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            picker.dismiss(animated: true)
            
            // We always expect `imagePickerController(:didFinishPickingMediaWithInfo:)` to supply the original image.
    //        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
          let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            imageView.image = image
            //CHECK IMAGE ML
            updateClassifications(for: image)
        }
    
      func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         print("lol")
       }
    
   //==========================================================
    
    //1. Anfrage mit Model und Eigenschaften festlegen
    lazy var classificationRequest: VNCoreMLRequest = {
           do {
           
               let model = try VNCoreMLModel(for: petsandmore().model)
               
               let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                //VERGLEICH FERTIG
                self?.processClassifications(for: request, error: error)
               })
               request.imageCropAndScaleOption = .centerCrop
               return request
           } catch {
               fatalError("Failed to load Vision ML model: \(error)")
           }
       }()


    func updateClassifications(for image: UIImage) {
        classificationLabel.text = "Classifying..."
             
        //guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        //BILD UND ORIANTATION IN RICHTIGES FORMAT GEBRACHT
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: CIImage(image:image)! , orientation: CGImagePropertyOrientation(image.imageOrientation))
            try! handler.perform([self.classificationRequest])
           
        }
    }
    
    func processClassifications(for request: VNRequest, error: Error?) {
         DispatchQueue.main.async {
           /* guard let results = request.results else {
                self.classificationLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }*/
            let results = request.results
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
        
            /*if classifications.isEmpty {
                self.classificationLabel.text = "Nothing recognized."
            } else {*/
                // Display top classifications ranked by confidence in the UI.
                let topClassifications = classifications.prefix(2)
                print(classifications)
                print(topClassifications)
                /*let descriptions = topClassifications.map { classification in
                    // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                   return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                }*/
            self.classificationLabel.text = "Classification:\n  \(topClassifications[0].identifier) \(Int(topClassifications[0].confidence*100))%\n"
            self.classificationLabel.text! +=  "\(topClassifications[1].identifier) \(Int(topClassifications[1].confidence*100))%\n"
            //}
        }
    }


}
