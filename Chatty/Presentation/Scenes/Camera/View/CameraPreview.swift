//
//  CameraPreview.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import AVFoundation
import Photos
import SwiftUI

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    var onTap: (CGPoint) -> Void

    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.backgroundColor = .black
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspect
        view.videoPreviewLayer.connection?.videoOrientation = .portrait

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
        return view
    }

    public func updateUIView(_ uiView: VideoPreviewView, context: Context) {}

    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }

        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: CameraPreview

        init(_ parent: CameraPreview) {
            self.parent = parent
        }

        @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
            let location = sender.location(in: sender.view)
            parent.onTap(location)
        }
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var image: Image?
    @Environment(\.presentationMode) private var presentationMode
    var isSaveToGallery = false

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerView>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePickerView

        init(_ parent: ImagePickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = Image(uiImage: uiImage)
                if parent.isSaveToGallery {
                    saveImageToGallery(uiImage)
                }
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func saveImageToGallery(_ image: UIImage) {
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, error in
                if success {
                    print("Image saved to gallery.")
                } else if let error = error {
                    print("Error saving image to gallery: \(error)")
                }
            }
        }
    }
}
