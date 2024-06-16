//
//  CameraView.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import SwiftUI

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel = CameraViewModel()

    @State private var isFocused = false
    @State private var isScaled = false
    @State private var focusLocation: CGPoint = .zero
    @State private var currentZoomFactor: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        ZStack {
                            Image("close")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundStyle(Color.white)
                        }
                        .frame(width: 32, height: 32)
                    }
                    Spacer()
                    Button {
                        viewModel.switchFlash()
                    } label: {
                        ZStack {
                            Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                .frame(width: 20, height: 20)
                                .foregroundStyle(viewModel.isFlashOn ? .yellow : .white)
                                .frame(width: 32, height: 32)
                        }
                    }
                }
                .padding(.horizontal)

                ZStack {
                    CameraPreview(session: viewModel.session) { tapPoint in
                        isFocused = true
                        focusLocation = tapPoint
                        viewModel.setFocus(point: tapPoint)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                    .gesture(MagnificationGesture()
                        .onChanged { value in
                            self.currentZoomFactor += value - 1.0 // Calculate the zoom factor change
                            self.currentZoomFactor = min(max(self.currentZoomFactor, 0.5), 10)
                            self.viewModel.zoom(with: currentZoomFactor)
                        })
//                        .animation(.easeInOut, value: 0.5)

                    if isFocused {
                        FocusView(position: $focusLocation)
                            .scaleEffect(isScaled ? 0.8 : 1)
                            .onAppear {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)) {
                                    self.isScaled = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                        self.isFocused = false
                                        self.isScaled = false
                                    }
                                }
                            }
                    }
                }

                HStack {
                    PhotoThumbnail(image: $viewModel.capturedImage)
                    Spacer()
                    CaptureButton { viewModel.captureImage() }
                    Spacer()
                    CameraSwitchButton { viewModel.switchCamera() }
                }
                .padding(20)
            }
            .alert(isPresented: $viewModel.showAlertError) {
                Alert(title: Text(viewModel.alertError.title), message: Text(viewModel.alertError.message), dismissButton: .default(Text(viewModel.alertError.primaryButtonTitle), action: {
                    viewModel.alertError.primaryAction?()
                }))
            }
            .alert(isPresented: $viewModel.showSettingAlert) {
                Alert(title: Text("Warning"), message: Text("Application doesn't have all permissions to use camera and microphone, please change privacy settings."), dismissButton: .default(Text("Go to settings"), action: {
                    self.openSettings()
                }))
            }
            .onAppear {
                viewModel.setupBindings()
                viewModel.requestCameraPermission()
            }
        }
    }

    func openSettings() {
        let settingsUrl = URL(string: UIApplication.openSettingsURLString)
        if let url = settingsUrl {
            UIApplication.shared.open(url, options: [:])
        }
    }
}

struct PhotoThumbnail: View {
    @Binding var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            } else {
                Rectangle()
                    .frame(width: 50, height: 50, alignment: .center)
                    .foregroundStyle(Color.black)
            }
        }
    }
}

struct CaptureButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .foregroundStyle(.white)
                .frame(width: 70, height: 70, alignment: .center)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.8), lineWidth: 2)
                        .frame(width: 59, height: 59, alignment: .center)
                )
        }
    }
}

struct CameraSwitchButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .foregroundStyle(Color.gray.opacity(0.2))
                .frame(width: 45, height: 45, alignment: .center)
                .overlay(
                    Image(systemName: "camera.rotate.fill")
                        .foregroundStyle(.white))
        }
    }
}

struct FocusView: View {
    @Binding var position: CGPoint

    var body: some View {
        Circle()
            .frame(width: 70, height: 70)
            .foregroundStyle(.clear)
            .border(Color.yellow, width: 1.5)
            .position(x: position.x, y: position.y)
    }
}

#Preview {
    CameraView()
}
