//
//  Recognizer.swift
//  RoemischeZahl
//
//  Created by Morten Bertz on 2021/05/02.
//

import Foundation
import Vision
import AVFoundation
import CoreImage
import SwiftUI
import XLIICore
import Combine

protocol Recognizing:AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    var videoAspectRatio: CGFloat {get set}
    var textOrientation: CGImagePropertyOrientation {get set}
    var photoOutput:AVCapturePhotoOutput? {get set}
    var session:AVCaptureSession? {get set}
}

class Recognizer:NSObject, Recognizing, SceneStability, ObservableObject{
    
    static let fullAreaROI:CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
    
    @Published var state:SceneStabilityState = .notSteady
    @Published var videoAspectRatio:CGFloat=1
//    @Published var foundElements = [TextElement]()
    
    let stream: AsyncStream<[TextElement]>
    internal let continuation: AsyncStream<[TextElement]>.Continuation
    
    var regionOfInterest = Recognizer.fullAreaROI
    
    let ciContext:CIContext
    
   let sequenceRequestHandler = VNSequenceRequestHandler()
    
    lazy var request: VNRecognizeTextRequest = VNRecognizeTextRequest(completionHandler: {[weak self] request, error in
        self?.recognizeTextHandler(request: request, error: error)
    })
   
    internal var transpositionHistoryPoints: [CGPoint] = []
    var previousPixelBuffer: CVPixelBuffer?
    
    var textOrientation = CGImagePropertyOrientation.up
       
    var currentlyAnalyzedPixelBuffer: CVPixelBuffer?
    var currentFrame=0
    
    weak var photoOutput:AVCapturePhotoOutput?
    weak var session: AVCaptureSession?
    
    @Published var image:UIImage?
    
    @Published var useROI:Bool = true{
        didSet{
            if useROI {
                self.regionOfInterest = defaultRegionOfInterest
            }
            else{
                self.regionOfInterest = Recognizer.fullAreaROI
            }
        }
    }
    
    var defaultRegionOfInterest:CGRect{
        switch self.textOrientation {
        case .left, .right:
            return CGRect(x: 0.25, y: 0.8, width: 0.5, height: 0.1)
        default:
            return CGRect(x: 0.15, y: 0.7, width: 0.7, height: 0.2)
        }
    }
    
    
    override init() {
        guard let device=MTLCreateSystemDefaultDevice() else{fatalError()}
        self.ciContext=CIContext(mtlDevice: device)
        
        let s = AsyncStream.makeStream(of: [TextElement].self)
        self.stream = s.stream
        self.continuation = s.continuation
        
        super.init()
        self.useROI = useROI
        request.recognitionLevel = .fast
        request.usesLanguageCorrection = false
        
        
    }
    
    func captureImage(){
        guard let types=self.photoOutput?.availablePhotoPixelFormatTypes else{
            return
        }
        let settings=AVCapturePhotoSettings(format: [kCVPixelBufferPixelFormatTypeKey as String:types[0]])
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    func start(){
        session?.startRunning()
        
    }
    
    func stop(){
        session?.stopRunning()
    }
    
    func recognizeTextHandler(request: VNRequest, error: Error?) {
       
        guard let results = request.results as? [VNRecognizedTextObservation] else {
            return
        }
        let elements=analyze(results: results, useROI: self.useROI)
        self.continuation.yield(elements)
//        Task{
//            self.foundElements=elements
//
//        }
       
    }
    
    
    nonisolated func analyze(results:[VNRecognizedTextObservation], useROI:Bool)->[TextElement]{
        let maximumCandidates = 1
        var elements=[TextElement]()
        
        for visionResult in results {
            guard let candidate = visionResult.topCandidates(maximumCandidates).first else { continue }
            
            
            candidate.string.enumerateSubstrings(in: candidate.string.startIndex..<candidate.string.endIndex, options: [.byWords], {s, r1, _, _ in
                guard let rect=try? candidate.boundingBox(for: r1)?.boundingBox,
                      let text=s else{
                    return
                }
                if useROI{
                    let convertedX=self.regionOfInterest.minX+self.regionOfInterest.width*rect.minX
                    let convertedY=self.regionOfInterest.minY+self.regionOfInterest.height*rect.minY
                    let convertedWidth=self.regionOfInterest.width * rect.width
                    let convertedHeight=self.regionOfInterest.height * rect.height
                    let convertedRect=CGRect(x: convertedX, y: convertedY, width: convertedWidth, height: convertedHeight)
                    elements.append(TextElement(text: text, rect: convertedRect))
                }
                else{
                    elements.append(TextElement(text: text, rect: rect))
                }
                
            })
            
        }
        return elements
    }
    
    @MainActor
    func analyze(image:CGImage) async -> [TextElement] {
        
        let handler = VNImageRequestHandler(cgImage:image, orientation: .up, options: [.ciContext:self.ciContext])
        let request=VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        do{
            try handler.perform([request])
            guard let results=request.results else{
                return [TextElement]()
            }
            return analyze(results: results, useROI: false)
        }
        catch let error{
            print(error.localizedDescription)
            return [TextElement]()
        }
        
    }
    
    
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let state=self.assessStability(sampleBuffer: sampleBuffer)
        
        if state == .steady, let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer){
            
            request.regionOfInterest = regionOfInterest
            
            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: textOrientation, options: [.ciContext:self.ciContext])
            do {
                try requestHandler.perform([request])
            } catch {
                print(error)
            }
        }
        
//        DispatchQueue.main.async {
//            self.state=state
//        }
    }
    
    

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let pixelBuffer=photo.pixelBuffer else{return}

        let ciImage=CIImage(cvPixelBuffer: pixelBuffer, options: [CIImageOption.applyOrientationProperty:true])
        let transform=ciImage.orientationTransform(for: textOrientation)
        
        let corrected=ciImage.transformed(by: transform)
        if let cg=ciContext.createCGImage(corrected, from: corrected.extent){
            let image=UIImage(cgImage: cg)
            self.stop()
            self.image=image
        }
        
        
    }
}
