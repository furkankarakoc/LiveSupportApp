//
//  ImagePicker.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedMedia: [MediaContent]
    @Environment(\.presentationMode) var presentationMode
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    var allowsEditing: Bool = false
    var mediaTypes: [String] = [UTType.image.identifier]
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = allowsEditing
        picker.mediaTypes = mediaTypes
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            
            if let image = info[.originalImage] as? UIImage {
                processSelectedImage(image)
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didCancel: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        private func processSelectedImage(_ image: UIImage) {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
            
            let tempDir = FileManager.default.temporaryDirectory
            let fileName = "image_\(UUID().uuidString).jpg"
            let fileURL = tempDir.appendingPathComponent(fileName)
            
            do {
                try imageData.write(to: fileURL)
                
                let thumbnailSize = CGSize(width: 150, height: 150)
                let thumbnailImage = image.preparingThumbnail(of: thumbnailSize)
                let thumbnailFileName = "thumb_\(fileName)"
                let thumbnailURL = tempDir.appendingPathComponent(thumbnailFileName)
                
                if let thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.7) {
                    try thumbnailData.write(to: thumbnailURL)
                }
                
                let mediaContent = MediaContent(
                    fileName: fileName,
                    fileSize: Int64(imageData.count),
                    mimeType: "image/jpeg",
                    mediaType: .image,
                    localPath: fileURL.path,
                    thumbnailPath: thumbnailURL.path
                )
                
                DispatchQueue.main.async {
                    self.parent.selectedMedia.append(mediaContent)
                }
                
            } catch {
                print("Error saving image: \(error)")
            }
        }
    }
}

// MARK: - Modern Photo Picker

@available(iOS 14.0, *)
struct ModernPhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedMedia: [MediaContent]
    @Environment(\.presentationMode) var presentationMode
    
    var selectionLimit: Int = 1
    var filter: PHPickerFilter = .images
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = filter
        configuration.selectionLimit = selectionLimit
        configuration.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ModernPhotoPicker
        
        init(_ parent: ModernPhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            for result in results {
                let itemProvider = result.itemProvider
                
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                        if let image = image as? UIImage {
                            self?.processSelectedImage(image, from: result)
                        }
                    }
                }
            }
        }
        
        private func processSelectedImage(_ image: UIImage, from result: PHPickerResult) {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
            
            let tempDir = FileManager.default.temporaryDirectory
            let fileName = "image_\(UUID().uuidString).jpg"
            let fileURL = tempDir.appendingPathComponent(fileName)
            
            do {
                try imageData.write(to: fileURL)
                
                // Thumbnail oluştur
                let thumbnailSize = CGSize(width: 150, height: 150)
                let thumbnailImage = image.preparingThumbnail(of: thumbnailSize)
                let thumbnailFileName = "thumb_\(fileName)"
                let thumbnailURL = tempDir.appendingPathComponent(thumbnailFileName)
                
                if let thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.7) {
                    try thumbnailData.write(to: thumbnailURL)
                }
                
                let mediaContent = MediaContent(
                    fileName: fileName,
                    fileSize: Int64(imageData.count),
                    mimeType: "image/jpeg",
                    mediaType: .image,
                    localPath: fileURL.path,
                    thumbnailPath: thumbnailURL.path
                )
                
                DispatchQueue.main.async {
                    self.parent.selectedMedia.append(mediaContent)
                }
                
            } catch {
                print("Error saving image: \(error)")
            }
        }
    }
}

// MARK: - Document Picker

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedMedia: [MediaContent]
    @Environment(\.presentationMode) var presentationMode
    
    var allowedContentTypes: [UTType] = [.pdf, .plainText, .rtf, .image]
    var allowsMultipleSelection: Bool = false
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedContentTypes, asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = allowsMultipleSelection
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            for url in urls {
                processSelectedDocument(at: url)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        private func processSelectedDocument(at url: URL) {
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let fileData = try Data(contentsOf: url)
                let tempDir = FileManager.default.temporaryDirectory
                let fileName = url.lastPathComponent
                let fileURL = tempDir.appendingPathComponent(fileName)
                
                try fileData.write(to: fileURL)
                
                let fileExtension = url.pathExtension.lowercased()
                let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp"]
                let mediaType: MediaType = imageExtensions.contains(fileExtension) ? .image : .document
                
                let mediaContent = MediaContent(
                    fileName: fileName,
                    fileSize: Int64(fileData.count),
                    mimeType: url.mimeType(),
                    mediaType: mediaType,
                    localPath: fileURL.path,
                    thumbnailPath: nil
                )
                
                DispatchQueue.main.async {
                    self.parent.selectedMedia.append(mediaContent)
                }
                
            } catch {
                print("Error processing document: \(error)")
            }
        }
    }
}

// MARK: - Extensions

extension URL {
    func mimeType() -> String {
        let pathExtension = self.pathExtension
        if let mimeType = UTType(filenameExtension: pathExtension)?.preferredMIMEType {
            return mimeType
        } else {
            return "application/octet-stream"
        }
    }
}
