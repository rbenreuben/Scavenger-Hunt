import UIKit
import AVFoundation

class QRCodeScannerViewController: UIViewController {
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView!

   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeQRScanner()
        
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
                print("Code value is: " + (String(describing: metadataObject.stringValue!)))
            }
        }
        
        
    }
    
    
}
