//
//  CustomArealsManagementView.swift
//  Customized Areal Screen Saver
//
//  Created by falcon on 2023/10/7.
//

import SwiftUI
import AppKit

struct CustomArealsManagementView: View {

    @ObservedObject var screenSaverManager: CustomScreenSaverManager
    
    @State var showAddDialog: Bool = false
    
    private func loadImageFromURL(_ imageURLString: String) -> NSImage{
        return NSImage(contentsOfFile: imageURLString) ?? NSImage(systemSymbolName: "questionmark.square.dashed", accessibilityDescription: nil)!
    }
    
    private func removeCustomScreenSaver(uuid: String){
        print("removeCustomScreenSaver \(uuid)")
        self.screenSaverManager.deleteScreenSaver(id: uuid)
    }
    
    private func openCustomAssetsInFinder(){
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: self.screenSaverManager.getCustomAssetsRootURL())
        print("openCustomAssetsInFinder")
    }
    
    private func getAssetSize(filePath: String) -> Int{
        do {
            let fileAtrribute = try FileManager.default.attributesOfItem(atPath: filePath)
            return fileAtrribute[FileAttributeKey.size] as! Int
        } catch {
            print(error)
        }
        return -1
    }
    
    let columns = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
     ]
    
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    self.showAddDialog = true
                }) {
                    Label("Add Custom Areal Screen Saver", systemImage: "plus")
                }.padding()
                Button(action: openCustomAssetsInFinder) {
                    Label("Open custom assets in finder", systemImage: "folder")
                }.padding()
            }.frame(alignment: .top)
            ScrollView{
                LazyVGrid(columns: columns){
                    ForEach($screenSaverManager.customArealCategorySubcategories) { customArealCategorySubcategory in
                        VStack{
                            Image(nsImage: loadImageFromURL(customArealCategorySubcategory.previewImage.wrappedValue))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 75)
                            Text(customArealCategorySubcategory.localizedNameKey.wrappedValue)
                            Text(customArealCategorySubcategory.representativeAssetID.wrappedValue).font(.system(size: 8))
                            Button(action: {
                                removeCustomScreenSaver(uuid: customArealCategorySubcategory.representativeAssetID.wrappedValue)
                            }) {
                                Label("Delete", systemImage: "trash")
                                    .foregroundStyle(.red)
                                    .font(.system(size: 10))
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAddDialog) {
            AddScreenSaverDialogView(screenSaverManager: screenSaverManager, showAddDialog: $showAddDialog)
                .frame(
                    width: (NSApplication.shared.windows.first?.frame.width)! / 2,
                    height: (NSApplication.shared.windows.first?.frame.height)! / 1.5
                )
        }
    }
}

//#Preview {
//    CustomArealsManagementView()
//}
