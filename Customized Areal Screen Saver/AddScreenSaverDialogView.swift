//
//  AddScreenSaverDialogView.swift
//  Customized Areal Screen Saver
//
//  Created by falcon on 2023/10/7.
//

import SwiftUI
import AVFoundation

struct AddScreenSaverDialogView: View {
    
    var screenSaverManager: CustomScreenSaverManager
    
    @Binding var showAddDialog: Bool
    
    @State private var screenSaverName: String = ""
    @State private var screenSaverDescription: String = ""
    @State private var assetVideoPath: String = ""
    @State private var previewImagePath: String = ""
    
    @State private var assetVideoDropZone = Image(systemName: "sparkles.tv")
    @State private var previewImageDropZone = Image(systemName: "photo")
    
    @State private var assetVideoDropZonePrompt = "Drop a Video"
    @State private var previewImageDropZonePrompt = "Drop a preview image"
    
    private func addCustomScreenSaver(){
        print("addCustomScreenSaver")
        self.showAddDialog = true
        self.screenSaverManager.addNewScreenSaver(screenSaverName: self.screenSaverName, screenSaverDescription: self.screenSaverDescription, videoPath: self.assetVideoPath, videoPreviewPath: self.previewImagePath, includeInShuffle: true)
    }
    
    private func extractPreviewFrameFromVideo(video: AVURLAsset) -> CGImage?{
        let imageGenerator = AVAssetImageGenerator(asset: video)
        do {
            let frame = try imageGenerator.copyCGImage(at: CMTime(value: CMTimeValue(0.0), timescale: 600), actualTime: nil)
            return frame
        } catch {
            print(error)
            return nil
        }
    }
    
    private func setAssetVideoPath(url: URL) {
        let path = url.path(percentEncoded: false)
        self.assetVideoPath = path
        self.assetVideoDropZonePrompt = self.assetVideoPath
        let previewFrame = self.extractPreviewFrameFromVideo(video: AVURLAsset(url: url))
        if (previewFrame != nil){
            let nsImage = NSImage(cgImage: previewFrame!, size: .zero)
            self.assetVideoDropZone = Image(nsImage: nsImage)
        }
    }
    
    private func setPreviewImagePath(url: URL){
        let path = url.path(percentEncoded: false)
        self.previewImagePath = path
        self.previewImageDropZonePrompt = self.previewImagePath
        print("previewImagePath: \(self.previewImagePath)")
        guard let nsImage = NSImage(contentsOfFile: self.previewImagePath) else {
            return
        }
        let previewImage = Image(nsImage: nsImage)
        self.previewImageDropZone = previewImage
    }
    
    private func handleDropAction(providers: Array<NSItemProvider>, callback: @escaping (URL) -> Void) -> Bool{
        if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
            _ = provider.loadObject(ofClass: URL.self) { object, error in
                print("url: \(object?.path() ?? "nil")")
                callback(object ?? URL(fileURLWithPath: ""))
            }
            return true
        }
        return false
    }
    
    
    var body: some View {
        Text("Add a new Areal screen saver").padding()
        VStack{
            HStack{
                TextField("Screen Saver Name", text: $screenSaverName)
                TextField("Screen Saver Description (Optional)", text: $screenSaverDescription)
            }.padding()
            GeometryReader{ geometry in
                HStack{
                    VStack{
                        assetVideoDropZone
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .font(Font.title.weight(.ultraLight))
                            .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                                handleDropAction(providers: providers, callback: setAssetVideoPath)
                            }
                        Text(assetVideoDropZonePrompt)
                    }
                    .frame(width: geometry.size.width * 0.5, height: 150)
                    VStack{
                        previewImageDropZone
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .font(Font.title.weight(.ultraLight))
                            .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                                handleDropAction(providers: providers, callback: setPreviewImagePath)
                            }
                        Text(previewImageDropZonePrompt)
                    }
                    .frame(width: geometry.size.width * 0.5, height: 150)
                }.padding()
            }
        }
        .padding()
        Spacer()
        HStack{
            Spacer()
            Button {
                self.showAddDialog = false
            } label: {
                Text("Cancel")
            }
            Button {
                self.addCustomScreenSaver()
                self.showAddDialog = false
            } label: {
                Text("Add")
            }
        }
        .padding()
    }
}

//#Preview {
//    AddScreenSaverDialogView()
//}
