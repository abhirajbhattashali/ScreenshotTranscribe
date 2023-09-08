//
//  PhotoLibraryChangeObserver.swift
//  Screenshot_LiveText
//
//  Created by Ashish Dutt on 08/09/23.
//

import SwiftUI
import Photos

class PhotoLibraryObserver: NSObject, PHPhotoLibraryChangeObserver {
    
    var onNewImageDetected: ((UIImage) -> Void)?
    
    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        if let image = fetchLatestImage() {
            onNewImageDetected?(image)
        }
    }
    
    private func fetchLatestImage() -> UIImage? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1

        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        guard let asset = fetchResult.firstObject else {
            return nil
        }

        var image: UIImage?

        let imageManager = PHImageManager.default()
        let imageSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)

        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.resizeMode = .exact
        options.deliveryMode = .highQualityFormat

        imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: options, resultHandler: {
            (resultImage, _) in
            image = resultImage
        })

        return image
    }
}
