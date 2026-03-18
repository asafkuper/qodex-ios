//
//  ImageCache.swift
//  Performance optimizations for images
//

import Foundation
import UIKit

actor ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        // Configure memory cache
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        // Setup disk cache
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = urls[0].appendingPathComponent("ImageCache")
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Clean up old files periodically
        Task {
            await cleanupOldFiles()
        }
    }
    
    // MARK: - Cache Operations
    
    func image(for key: String) -> UIImage? {
        let nsKey = key as NSString
        
        // Check memory cache first
        if let image = cache.object(forKey: nsKey) {
            return image
        }
        
        // Check disk cache
        let fileURL = cacheDirectory.appendingPathComponent(key.md5)
        if let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            // Store in memory cache
            cache.setObject(image, forKey: nsKey)
            return image
        }
        
        return nil
    }
    
    func setImage(_ image: UIImage, for key: String) {
        let nsKey = key as NSString
        
        // Store in memory cache
        cache.setObject(image, forKey: nsKey)
        
        // Store in disk cache
        let fileURL = cacheDirectory.appendingPathComponent(key.md5)
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: fileURL)
        }
    }
    
    func removeImage(for key: String) {
        cache.removeObject(forKey: key as NSString)
        
        let fileURL = cacheDirectory.appendingPathComponent(key.md5)
        try? fileManager.removeItem(at: fileURL)
    }
    
    func clearCache() {
        cache.removeAllObjects()
        
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Cleanup
    
    private func cleanupOldFiles() {
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.contentModificationDateKey]) else {
            return
        }
        
        let oneWeekAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        
        for file in files {
            guard let attributes = try? fileManager.attributesOfItem(atPath: file.path),
                  let modificationDate = attributes[.modificationDate] as? Date else {
                continue
            }
            
            if modificationDate < oneWeekAgo {
                try? fileManager.removeItem(at: file)
            }
        }
    }
}

// MARK: - Image Loading

import SwiftUI

struct CachedAsyncImage: View {
    let url: String
    let placeholder: Image
    
    @State private var image: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                placeholder
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay(
                        Group {
                            if isLoading {
                                ProgressView()
                                    .tint(QodeXColors.gold)
                            }
                        }
                    )
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        // Check cache first
        if let cached = await ImageCache.shared.image(for: url) {
            image = cached
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        guard let imageURL = URL(string: url) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: imageURL)
            guard let loadedImage = UIImage(data: data) else { return }
            
            // Store in cache
            await ImageCache.shared.setImage(loadedImage, for: url)
            
            image = loadedImage
        } catch {
            print("Failed to load image: \(error)")
        }
    }
}

// MARK: - Image Downsampling

extension UIImage {
    func downsampled(to size: CGSize) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        
        guard let data = self.jpegData(compressionQuality: 1.0),
              let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            return nil
        }
        
        let maxDimensionInPixels = max(size.width, size.height) * UIScreen.main.scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }
        
        return UIImage(cgImage: downsampledImage)
    }
}

// MARK: - String Extension for MD5

import CryptoKit

extension String {
    var md5: String {
        let data = Data(self.utf8)
        let hash = Insecure.MD5.hash(data: data)
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}
