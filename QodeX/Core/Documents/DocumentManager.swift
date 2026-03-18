//
//  DocumentManager.swift
//  File sharing and document provider
//

import Foundation
import UIKit
import UniformTypeIdentifiers

class DocumentManager: NSObject, UIDocumentPickerDelegate {
    static let shared = DocumentManager()
    
    weak var presentingViewController: UIViewController?
    var completionHandler: ((URL?) -> Void)?
    
    // MARK: - Import Document
    func importDocument(from viewController: UIViewController, completion: @escaping (URL?) -> Void) {
        self.presentingViewController = viewController
        self.completionHandler = completion
        
        let supportedTypes: [UTType] = [
            .pdf,
            .plainText,
            .image,
            .data
        ]
        
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        picker.shouldShowFileExtensions = true
        
        viewController.present(picker, animated: true)
    }
    
    // MARK: - Export Document
    func exportDocument(_ url: URL, from viewController: UIViewController) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        viewController.present(activityVC, animated: true)
    }
    
    // MARK: - Save Chart as Document
    func saveChartAsDocument(chartData: ChartExportData) async throws -> URL {
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        let fileName = "\(chartData.userName)_Numerology_Chart_\(Date().ISO8601Format()).pdf"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        // Generate PDF
        let pdfData = try await generateChartPDF(data: chartData)
        try pdfData.write(to: fileURL)
        
        return fileURL
    }
    
    // MARK: - Import Birth Data
    func importBirthData(from url: URL) -> BirthData? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        
        // Try JSON first
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return parseBirthData(from: json)
        }
        
        // Try CSV
        if let csv = String(data: data, encoding: .utf8) {
            return parseBirthData(fromCSV: csv)
        }
        
        return nil
    }
    
    // MARK: - UIDocumentPickerDelegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            completionHandler?(nil)
            return
        }
        
        // Security-scoped resource
        guard url.startAccessingSecurityScopedResource() else {
            completionHandler?(nil)
            return
        }
        
        defer { url.stopAccessingSecurityScopedResource() }
        
        completionHandler?(url)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        completionHandler?(nil)
    }
    
    // MARK: - Private Methods
    private func generateChartPDF(data: ChartExportData) async throws -> Data {
        // Use the ExportManager to generate PDF
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                if let pdfData = await ExportManager.shared.generateChartPDF(for: data.user) {
                    continuation.resume(returning: pdfData)
                } else {
                    continuation.resume(throwing: DocumentError.pdfGenerationFailed)
                }
            }
        }
    }
    
    private func parseBirthData(from json: [String: Any]) -> BirthData? {
        guard let name = json["name"] as? String,
              let birthDateString = json["birthDate"] as? String else {
            return nil
        }
        
        let formatter = ISO8601DateFormatter()
        guard let birthDate = formatter.date(from: birthDateString) else { return nil }
        
        return BirthData(
            name: name,
            birthDate: birthDate,
            birthTime: json["birthTime"] as? String,
            birthLocation: json["birthLocation"] as? String
        )
    }
    
    private func parseBirthData(fromCSV csv: String) -> BirthData? {
        let lines = csv.components(separatedBy: .newlines)
        guard lines.count > 1 else { return nil }
        
        // Parse header and data
        // name,birthDate,birthTime,birthLocation
        let values = lines[1].components(separatedBy: ",")
        guard values.count >= 2 else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let birthDate = formatter.date(from: values[1]) else { return nil }
        
        return BirthData(
            name: values[0],
            birthDate: birthDate,
            birthTime: values.count > 2 ? values[2] : nil,
            birthLocation: values.count > 3 ? values[3] : nil
        )
    }
}

// MARK: - Supporting Types
struct ChartExportData {
    let user: QodeXUser
    let userName: String
    let exportDate: Date
    let includeDetails: Bool
}

struct BirthData {
    let name: String
    let birthDate: Date
    let birthTime: String?
    let birthLocation: String?
}

enum DocumentError: Error {
    case pdfGenerationFailed
    case invalidFileFormat
    case importFailed
}

// MARK: - File Provider Extension Support
class QodeXFileProvider: NSObject {
    // Support for browsing QodeX files in Files app
    // Would implement NSFileProviderExtension for full integration
}
