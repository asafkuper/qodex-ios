//
//  PaginationHelper.swift
//  Efficient data loading with pagination
//

import Foundation
import FirebaseFirestore

actor PaginationHelper<T: Identifiable> {
    private let pageSize: Int
    private var lastDocument: DocumentSnapshot?
    private var isFetching = false
    private var hasMoreData = true
    
    var items: [T] = []
    
    init(pageSize: Int = 20) {
        self.pageSize = pageSize
    }
    
    func fetchNextPage(query: Query) async throws -> [T] {
        guard !isFetching && hasMoreData else {
            return []
        }
        
        isFetching = true
        defer { isFetching = false }
        
        var query = query.limit(to: pageSize)
        
        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }
        
        let snapshot = try await query.getDocuments()
        
        guard !snapshot.documents.isEmpty else {
            hasMoreData = false
            return []
        }
        
        lastDocument = snapshot.documents.last
        
        // Parse documents to type T
        // This is a generic placeholder - actual parsing would depend on T
        let newItems: [T] = snapshot.documents.compactMap { document in
            // Parse document data to T
            return nil // Replace with actual parsing
        }
        
        items.append(contentsOf: newItems)
        
        if snapshot.documents.count < pageSize {
            hasMoreData = false
        }
        
        return newItems
    }
    
    func reset() {
        items.removeAll()
        lastDocument = nil
        hasMoreData = true
        isFetching = false
    }
    
    var canLoadMore: Bool {
        !isFetching && hasMoreData
    }
}

// MARK: - Lazy Loading View Modifier

import SwiftUI

struct LazyLoadingModifier: ViewModifier {
    let action: () async -> Void
    @State private var isLoading = false
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !isLoading else { return }
                isLoading = true
                
                Task {
                    await action()
                    isLoading = false
                }
            }
    }
}

extension View {
    func lazyLoad(action: @escaping () async -> Void) -> some View {
        modifier(LazyLoadingModifier(action: action))
    }
}

// MARK: - Prefetching

class PrefetchManager {
    static let shared = PrefetchManager()
    
    private let queue = OperationQueue()
    private var prefetchedURLs: Set<String> = []
    
    private init() {
        queue.maxConcurrentOperationCount = 3
    }
    
    func prefetch(urls: [String]) {
        for url in urls where !prefetchedURLs.contains(url) {
            prefetchedURLs.insert(url)
            
            queue.addOperation {
                guard let imageURL = URL(string: url) else { return }
                
                URLSession.shared.dataTask(with: imageURL) { data, _, _ in
                    guard let data = data,
                          let image = UIImage(data: data) else { return }
                    
                    Task {
                        await ImageCache.shared.setImage(image, for: url)
                    }
                }.resume()
            }
        }
    }
    
    func cancelPrefetching() {
        queue.cancelAllOperations()
    }
}

// MARK: - Memory Management

import UIKit

class MemoryManager {
    static let shared = MemoryManager()
    
    private init() {
        // Monitor memory warnings
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    @objc private func didReceiveMemoryWarning() {
        // Clear caches
        Task {
            await ImageCache.shared.clearCache()
        }
        
        // Clear temporary data
        URLCache.shared.removeAllCachedResponses()
    }
    
    var availableMemory: UInt64 {
        let info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        guard kerr == KERN_SUCCESS else { return 0 }
        return info.resident_size
    }
}
