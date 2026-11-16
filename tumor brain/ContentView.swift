//
//  ContentView.swift
//  tumor brain
//
//  Created by Rimah on 30/05/1448 AH.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var result: ClassificationResult?
    @State private var isLoading = false

    // كاميرا
    @State private var showCamera = false

    var body: some View {
        VStack(spacing: 20) {
            Text("كشف أورام الدماغ")
                .font(.title.bold())

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.gray.opacity(0.15))
                    .frame(height: 300)
                    .overlay(Text("اختاري صورة MRI").foregroundStyle(.secondary))
            }

            HStack {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("اختيار صورة", systemImage: "photo")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    showCamera = true
                } label: {
                    Label("الكاميرا", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }

            if isLoading {
                ProgressView()
            } else if let result {
                VStack(spacing: 6) {
                    Text(result.label == "yes" ? "يوجد ورم محتمل" : "لا يوجد ورم")
                        .font(.title2.bold())
                        .foregroundStyle(result.label == "yes" ? .red : .green)
                    Text("نسبة الثقة: \(Int(result.confidence * 100))%")
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text("مشروع تعليمي وليس أداة تشخيص طبي")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .environment(\.layoutDirection, .rightToLeft)
        .onChange(of: selectedItem) { _, newItem in
            Task { await load(newItem) }
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker(image: $image) { capturedImage in
                if let uiImage = capturedImage {
                    self.image = uiImage
                    self.result = nil
                    self.isLoading = true
                    TumorClassifier.classify(uiImage) { r in
                        self.result = r
                        self.isLoading = false
                    }
                }
                showCamera = false
            }
        }
    }

    func load(_ item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else { return }
        image = uiImage
        result = nil
        isLoading = true
        TumorClassifier.classify(uiImage) { r in
            result = r
            isLoading = false
        }
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var completion: (UIImage?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                  didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let selected = info[.originalImage] as? UIImage
            parent.image = selected
            parent.completion(selected)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.completion(nil)
        }
    }
}

#Preview {
    ContentView()
}
