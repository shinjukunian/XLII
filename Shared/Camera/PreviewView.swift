//
//  PreviewView.swift
//  RoemischeZahl
//
//  Created by Morten Bertz on 2021/05/02.
//

import Foundation
import SwiftUI
import AVFoundation
import Combine

#if os(macOS)
import AppKit
typealias MyView = NSView
#else
import UIKit
typealias MyView = UIView
#endif


#if os(macOS)
struct PreviewHolder: NSViewRepresentable {
        
    let recognizer:Recognizer
    
    @Binding var zoomLevel:CGFloat
    
    init(recognizer:Recognizer, zoomScale:Binding<CGFloat>) {
        self.recognizer=recognizer
        self._zoomLevel=zoomScale
    }

    func makeNSView(context: NSViewRepresentableContext<PreviewHolder>) -> PreviewView {
        return PreviewView(delegate: self.recognizer)
    }

    func updateNSView(_ uiView: PreviewView, context: NSViewRepresentableContext<PreviewHolder>) {
        uiView.zoomLevel=zoomLevel
    }

    typealias NSViewType = PreviewView
}

#elseif canImport(UIKit)
struct PreviewHolder: UIViewRepresentable {

    let recognizer:Recognizer
    
    @Binding var zoomLevel:CGFloat
    
    init(recognizer:Recognizer, zoomScale:Binding<CGFloat>) {
        self.recognizer=recognizer
        self._zoomLevel=zoomScale
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.zoomLevel=zoomLevel
    }
    
    func makeUIView(context: Context) -> PreviewView {
        let p=PreviewView(delegate: recognizer)
        return p
    }
    
    
    typealias UIViewType = PreviewView
    
}
#endif


class PreviewView: MyView{
    private var captureSession: AVCaptureSession?
    var videoDataOutput = AVCaptureVideoDataOutput()
    let videoDataOutputQueue = DispatchQueue(label: "com.telethon.VideoDataOutputQueue")

    var cancelables = Set<AnyCancellable>()
    
    var zoomLevel:CGFloat = 1.5{
        didSet{
            do {
                #if os(iOS)
                guard let device=(captureSession?.inputs.first as? AVCaptureDeviceInput)?.device
                else {
                    return
                }
                try device.lockForConfiguration()
                device.videoZoomFactor = max(min(zoomLevel,device.maxAvailableVideoZoomFactor),1)
                device.autoFocusRangeRestriction = .near
                device.unlockForConfiguration()
                #endif
            } catch {
                print("Could not set zoom level due to error: \(error)")
                return
            }
        }
    }
    
    weak var delegate:Recognizing?
    
    var bufferAspectRatio:CGFloat=1
    
    init(delegate: Recognizing) {
        self.delegate=delegate

        super.init(frame: .zero)
        

        var allowedAccess = false
        let blocker = DispatchGroup()
        blocker.enter()
        AVCaptureDevice.requestAccess(for: .video) { flag in
            allowedAccess = flag
            blocker.leave()
        }
        blocker.wait()

        if !allowedAccess {
            print("!!! NO ACCESS TO CAMERA")
            return
        }
        
        self.setupCamera()
        

        // instead of below, use layerClass on iOS
        #if canImport(AppKit)
        self.wantsLayer = true
        self.layer = AVCaptureVideoPreviewLayer()
        #endif
    }
    
    func setupCamera(){
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            print("Could not create capture device.")
            return
        }
        let session = AVCaptureSession()
        session.beginConfiguration()
        
        if videoDevice.supportsSessionPreset(.hd4K3840x2160) {
//            session.sessionPreset = AVCaptureSession.Preset.hd4K3840x2160
            bufferAspectRatio = 3840.0 / 2160.0
        } else if videoDevice.supportsSessionPreset(.hd1920x1080) {
//            session.sessionPreset = AVCaptureSession.Preset.hd1920x1080
            bufferAspectRatio = 1920.0 / 1080.0
        }
        else if videoDevice.supportsSessionPreset(.hd1280x720){
//            session.sessionPreset = AVCaptureSession.Preset.hd1920x1080
            bufferAspectRatio = 1280.0 / 720.0
        }
        else{
            bufferAspectRatio=1
        }

        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
            session.canAddInput(videoDeviceInput)
            else { return }
        session.addInput(videoDeviceInput)
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
        videoDataOutput.setSampleBufferDelegate(delegate, queue: videoDataOutputQueue)
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }

        let photo=AVCapturePhotoOutput()
        if session.canAddOutput(photo){
            session.addOutput(photo)
            delegate?.photoOutput=photo
        }
        
        session.commitConfiguration()
        delegate?.session=session
#if os(macOS)
        self.delegate?.videoAspectRatio=bufferAspectRatio
#else
        let l=self.zoomLevel
        self.zoomLevel=l
        updateOrientation()
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .sink(receiveValue: {[weak self] _ in
                self?.updateOrientation()
            }).store(in: &cancelables)
        
        
        
#endif
        
        
        self.captureSession = session
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }

    
    func moveToSuperView(){
        if nil != self.superview {
            self.videoPreviewLayer.session = self.captureSession
            self.videoPreviewLayer.videoGravity = .resizeAspect
            self.captureSession?.startRunning()
        } else {
            self.captureSession?.stopRunning()
        }
    }
    
    #if canImport(AppKit)
    override func viewDidMoveToSuperview() { // on iOS .didMoveToSuperview
        super.viewDidMoveToSuperview()
        self.moveToSuperView()
    }
    
    override func layout() {
        super.layout()
        
    }
    
    #else
    override class var layerClass: AnyClass{
        return AVCaptureVideoPreviewLayer.self
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.moveToSuperView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func updateOrientation(){
        let orientation = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.interfaceOrientation ?? .portrait
        
        switch orientation {
        case .landscapeLeft:
            self.delegate?.textOrientation = CGImagePropertyOrientation.down
        case .landscapeRight:
            self.delegate?.textOrientation = CGImagePropertyOrientation.up
        case .portraitUpsideDown:
            self.delegate?.textOrientation = CGImagePropertyOrientation.left
            self.delegate?.videoAspectRatio=1/bufferAspectRatio
        default:
            self.delegate?.textOrientation = CGImagePropertyOrientation.right
            self.delegate?.videoAspectRatio=1/bufferAspectRatio
        }
        (self.layer as? AVCaptureVideoPreviewLayer)?.connection?.videoOrientation = AVCaptureVideoOrientation(deviceOrientation: orientation) ?? .portrait
    
    }
    
    #endif
    
}
