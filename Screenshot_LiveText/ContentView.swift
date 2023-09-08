//
//  ContentView.swift
//  Screenshot_LiveText
//
//  Created by Ashish Dutt on 08/09/23.
//

import SwiftUI
import Photos
import Vision

struct ContentView: View {
    @StateObject private var viewModel = PhotoLibraryViewModel()
    
    var body: some View {
        VStack {
            if let text = viewModel.detectedText {
                Text(text)
            } else {
                Text("Waiting for new images...")
            }
        }
        .onAppear {
            PHPhotoLibrary.requestAuthorization { _ in }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class PhotoLibraryViewModel: ObservableObject {
    @Published var detectedText: String?
    
    private var photoObserver: PhotoLibraryObserver?

    init() {
        photoObserver = PhotoLibraryObserver()
        photoObserver?.onNewImageDetected = { [weak self] image in
            self?.processImageForText(image)
        }
    }
    
    private func processImageForText(_ image: UIImage) {
        guard let cgImage = image.cgImage else {
            return
        }
        
        let request = VNRecognizeTextRequest { [weak self] (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }

            let detectedTexts = observations.compactMap { $0.topCandidates(1).first?.string }
            DispatchQueue.main.async {
                self?.detectedText = detectedTexts.joined(separator: "\n")
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
            } catch {
                print("Failed to perform text recognition request: \(error.localizedDescription)")
            }
        }
    }
}
