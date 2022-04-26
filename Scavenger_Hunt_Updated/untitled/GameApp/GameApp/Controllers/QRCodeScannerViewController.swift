import UIKit
import AVFoundation
import Firebase


class QRCodeScannerViewController: UIViewController {
    var myName:String!
    var didScan:Bool!
    var captureSession = AVCaptureSession()
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView!
    var game:gameInformation!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "scan2Game"){
            let destinationVC = segue.destination as!
                GamePlayViewController
            
            
            destinationVC.game = self.game
            destinationVC.name = self.myName
            game.listner?.remove()
            game.clueListener?.remove()
            game.playersListener?.remove()
            game.yourPlayerListener?.remove()
            game = nil
        
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeQRScanner()
        game.loadClueData {
            print("updated clue data")
        }
            didScan=false
        print(game.clueInfo["2"]!["howManySolves"])   
    }
    
    private func initializeQRScanner(){
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = discoverySession.devices.first else {
            print("No device found")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            
            let videoMetaDataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(videoMetaDataOutput)
            
            videoMetaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            videoMetaDataOutput.metadataObjectTypes = [.qr]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            qrCodeFrameView = UIView()
            if qrCodeFrameView == qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2.0
                
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
            
            captureSession.startRunning()
        } catch {
            print(error)
            return
        }
        
    }
   

}

extension QRCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        
        qrCodeFrameView.frame = .zero
        if metadataObjects.count == 0 {
            print("No code found.")
            return
        }
        
        let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObject.type == .qr {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject)
            qrCodeFrameView.frame = barCodeObject!.bounds
            if metadataObject.stringValue != nil {
                let codeValue = (String(describing: metadataObject.stringValue!))
                print("Code value is: " + (String(describing: metadataObject.stringValue!)))
                
                
                
                if didScan==false &&    codeValue.prefix(7) == (self.game.joinCode! + "CLU")   {

                    let clueEndIndex = codeValue.firstIndex(of: "_") ?? codeValue.endIndex
                    if clueEndIndex != codeValue.endIndex && clueEndIndex > codeValue.index(codeValue.startIndex,offsetBy: 7){
                        
                        
                        let clueNum = codeValue[codeValue.index(codeValue.startIndex,offsetBy: 7) ..<  clueEndIndex]
                        if String(clueNum) != ""{
                            var uhhnum=true
                            for char in String(clueNum){
                                if char.isNumber == false{
                                    uhhnum = false
                                    break
                                }
                                if uhhnum==true &&  Int(clueNum) != nil && Int(clueNum)! <= self.game.numClues{
                                    
                                    var clueCode = codeValue[clueEndIndex ..< codeValue.endIndex ]
                                    if String(clueCode).count == 5 {
                                        clueCode = clueCode.dropFirst()
                                        print(clueNum)
                                        print(clueCode)
                                        guard String(clueCode) == self.game.clueInfo[String(clueNum)]!["qrCode"] as! String
                                        else {
                                            print("error")
                                            return
                                        }
                                        print("success")
                                        didScan=true
                                        let db=Firestore.firestore()
                    
                                        db.collection("currentGames").document(self.game.joinCode!).collection("clues").document("clue"+String(clueNum)).updateData(["howManySolves":(self.game.clueInfo[ String(clueNum)]!["howManySolves"] as! Int)+1])
                                        db.collection("currentGames").document(game.joinCode!).collection("participants").document(myName).updateData(["solveds": (self.game.myInfo["solveds"] as! String) + ","+String(clueNum), "points": (self.game.myInfo["points"] as! Int) + (self.game.clueInfo[String(clueNum)]!["points"] as! Int)])
                                        
                                        performSegue(withIdentifier: "scan2Game", sender: nil)
                                        
                                    }
                                    
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                   
                    

                }
                
            }
        }
        
        
    }
    
    
}
