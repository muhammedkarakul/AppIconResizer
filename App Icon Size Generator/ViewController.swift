//
//  ViewController.swift
//  App Icon Size Generator
//
//  Created by Muhammed Karakul on 25.01.2019.
//  Copyright © 2019 Muhammed Karakul. All rights reserved.
//

import Cocoa



class ViewController: NSViewController {
    
    private enum PlatformType: String {
        case ios
        case macos
        case watchkit
        case android
        case all
    }
    
    @IBOutlet var imageView: NSImageView!
    @IBOutlet var dropView: DropView!
    
    
    private var selectedPlatformType: String?
    
    private var platforms = [String : Any]()
    
    private var toBeSavedImages = [String : NSImage]()
    
    //private var selectedPlatformsIconSizes = [String : Int]()
    
    private var selectedPlatform: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let number = 1995
        let str = "alidasdasdasdsa"
        print("size of int: \(MemoryLayout<Int>.size)")
        print("size of number: \(MemoryLayout.size(ofValue: number))")
        print("size of string: \(MemoryLayout<String>.size)")
        print("size of str: \(MemoryLayout.size(ofValue: str))")
        
        dropView.viewController = self
        
        getPlatformsFromPlistFile()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func segmentDidChange(_ sender: NSSegmentedControl) {
        switch sender.indexOfSelectedItem {
        case 0: selectedPlatformType = PlatformType.ios.rawValue
        case 1: selectedPlatformType = PlatformType.macos.rawValue
        case 2: selectedPlatformType = PlatformType.watchkit.rawValue
        case 3: selectedPlatformType = PlatformType.android.rawValue
        case 4: selectedPlatformType = PlatformType.all.rawValue
        default: selectedPlatformType = nil
        }
    }
    
    @IBAction func browseFile(_ sender: NSButton) {
        
        if selectedPlatformType != nil {
            
            let fileSelectionDialog = NSOpenPanel()
            
            fileSelectionDialog.title = "Choose a image file"
            fileSelectionDialog.allowedFileTypes = ["png", "jpg", "psd"]
            
            if fileSelectionDialog.runModal() == .OK {
                let result = fileSelectionDialog.url
                
                resizeAndSaveImage(withURL: result)
                
            } else {
                return
            }
        } else {
            showAlert(withMessage: "You must choose a platform!")
        }
        
    }
    
    public func dropFile(withPath path: String?) {
        if selectedPlatformType != nil {
            if let selectedFilePath = path {
                resizeAndSaveImage(withURL: URL(string: selectedFilePath))
            }
        } else {
            showAlert(withMessage: "You must choose a platform!")
        }
    }
    
    private func showAlert(withMessage message: String) {
        let error = NSError(domain: "Hata", code: 0, userInfo: nil)
        let alert = NSAlert(error: error)
        alert.messageText = message
        alert.runModal()
    }
    
    private func resizeAndSaveImage(withURL url: URL?) {
        if let url = url {
            let selectedFilePath = url.path
            guard let image = NSImage(byReferencingFile: selectedFilePath) else { return }
            let fileSavingDialog = NSSavePanel()
            
            fileSavingDialog.title = "Choose save directory"
            fileSavingDialog.allowedFileTypes = []
            
            if fileSavingDialog.runModal() == .OK {
                
                guard let documentDirectory = fileSavingDialog.directoryURL else { return }
                
                do {
                    guard let selectedPlatform = selectedPlatformType else { return }
                    guard let selectedPlatformIconSizes = platforms[selectedPlatform] as? [String : Int] else { return }
                    for (fileName, iconSize) in selectedPlatformIconSizes {
                        guard let resizedImage = resizeImage(image: image, byWidth: iconSize / 2, andHeight: iconSize / 2) else { return }
                        guard let saveLocationURL = URL(string:("\(documentDirectory)\(fileName).png")) else { return }
                        try resizedImage.tiffRepresentation?.write(to: saveLocationURL )
                    }
                } catch {
                    print(error.localizedDescription)
                }
                
            } else {
                return
            }
            
        }
    }
    
    private func resizeImage(image: NSImage, byWidth width: Int, andHeight height: Int) -> NSImage? {
        let destinationSize = NSMakeSize(CGFloat(width), CGFloat(height))
        let newImage = NSImage(size: destinationSize)
        newImage.lockFocus()
        image.draw(in: NSMakeRect(0, 0, destinationSize.width, destinationSize.height), from: NSMakeRect(0, 0, image.size.width, image.size.height), operation: NSCompositingOperation.sourceOver , fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = destinationSize
        guard let tiffRepresentation = newImage.tiffRepresentation else { return nil }
        guard let resizedImage = NSImage(data: tiffRepresentation) else { return nil }
        return resizedImage
    }

//    @IBAction func platformTypeStateChanged(_ sender: Any) {
//        if let selectedPlatformIconSizes = platforms[selectedPlatformType] as? [String : Int] {
//            //self.selectedPlatformsIconSizes = selectedPlatformIconSizes
//            
//        }
//    }
    
    private func getPlatformsFromPlistFile() {
        guard let platformIconSizePlistPath = Bundle.main.path(forResource: "PlatformIconSizeInfo", ofType: "plist") else { return }
        guard let platformIconSizes = NSDictionary(contentsOfFile: platformIconSizePlistPath) else { return }
        guard let platforms = platformIconSizes["Platform"] as? [String : Any] else { return }
        self.platforms = platforms
    }
}

