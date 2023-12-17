//
//  CustomScreenSaverManager.swift
//  Customized Aerial Screen Saver
//
//  Created by falcon on 2023/10/7.
//

import Foundation

struct AssetsURLCollection{
    let systemAssetsRootURL: URL
    let systemAssetsPreviewURL: URL
    let systemAssetsVideoURL: URL
    let systemAssetsEntriesURL: URL
    let customAssetsRootURL: URL
    let customAssetsPreviewURL: URL
    let customAssetsVideoURL: URL
    let customAssetsEntriesURL: URL
}

class CustomScreenSaverManager: ObservableObject {
    
    @Published var customAerialCategorySubcategories: Array<TVIdleScreenEntryCategorySubcategory> = []
    
    private let fileManager: FileManager = FileManager()
    private let customAerialCategoryUUID: String = "C8EE7C2A-8025-4094-91C2-9637B6D2A64D"
    private var userPassword: String? = nil
    
    var assetsURLCollection: AssetsURLCollection
    
    private var TVIdleScreenEntries: TVIdleScreenEntry?
    private var customAerialCategoryIndex: Int = -1
    
    
    private let defaultSystemAssetsRootPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .systemDomainMask).first!.appending(path: "com.apple.idleassetsd").path(percentEncoded: false)
    private let defaultCustomAssetsRootPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appending(path: "com.xtl.customizedarealscreensaver").path(percentEncoded: false)
    
    init(
        systemAssetsRootPath: String? = nil,
        customAssetsRootPath: String? = nil
    ) {
        let _systemAssetsRootPath = systemAssetsRootPath ?? defaultSystemAssetsRootPath
        let _customAssetsRootPath = customAssetsRootPath ?? defaultCustomAssetsRootPath
        
        
        let systemAssetsRootURL = URL(fileURLWithPath: _systemAssetsRootPath)
        let customAssetsRootURL = URL(fileURLWithPath: _customAssetsRootPath)
        
        print(systemAssetsRootURL.path(percentEncoded: false))
        print(customAssetsRootURL.path(percentEncoded: false))
        
        self.assetsURLCollection = AssetsURLCollection(
            systemAssetsRootURL: systemAssetsRootURL,
            systemAssetsPreviewURL: systemAssetsRootURL.appending(component: "snapshots"),
            systemAssetsVideoURL: systemAssetsRootURL.appending(component: "Customer"),
            systemAssetsEntriesURL: systemAssetsRootURL.appending(component: "Customer/entries.json"),
            customAssetsRootURL: customAssetsRootURL,
            customAssetsPreviewURL: customAssetsRootURL.appending(component: "asset-preview"),
            customAssetsVideoURL: customAssetsRootURL.appending(component: "video"),
            customAssetsEntriesURL: customAssetsRootURL.appending(component: "entries.json")
        )
        
        var isDir: ObjCBool = true
        if (!self.fileManager.fileExists(atPath: _customAssetsRootPath, isDirectory: &isDir)){
            self._createUserDataDirectory(customAssetsPreviewURL: self.assetsURLCollection.customAssetsPreviewURL, customAssetsVideoURL: self.assetsURLCollection.customAssetsVideoURL)
        }
        self._checkEntriesFileExists()
        self._loadEntriesConfig()
        self._checkCustomAerialCategoryExists()
    }
    
    private func _createUserDataDirectory(customAssetsPreviewURL: URL, customAssetsVideoURL: URL){
        do{
            try self.fileManager.createDirectory(
                at: customAssetsPreviewURL,
                withIntermediateDirectories: true
            )
            try self.fileManager.createDirectory(
                at: customAssetsVideoURL,
                withIntermediateDirectories: true
            )
        }
        catch{
            print(error)
        }
    }
    
    private func _loadEntriesConfig(){
        do {
            let data = try Data(contentsOf: self.assetsURLCollection.customAssetsEntriesURL, options: .mappedIfSafe)
            self.TVIdleScreenEntries = try JSONDecoder().decode(TVIdleScreenEntry.self, from: data)
        } catch {
            print(error)
        }
    }
    
    private func _backupDefaultEntries(){
        do {
            try self.fileManager.copyItem(
                at: self.assetsURLCollection.systemAssetsEntriesURL,
                to: self.assetsURLCollection.customAssetsEntriesURL
            )
            try self.fileManager.copyItem(
                at: self.assetsURLCollection.systemAssetsEntriesURL,
                to: self.assetsURLCollection.customAssetsRootURL.appending(path: "system-default-entries.json")
            )
        } catch {
            print(error)
        }
    }
    
    private func _updateCustomAerialCategorySubcategories(){
        print("self.customAerialCategoryIndex \(self.customAerialCategoryIndex)")
        self.customAerialCategorySubcategories = self.TVIdleScreenEntries!.categories[self.customAerialCategoryIndex].subcategories
    }
    
    private func _checkCustomAerialCategoryExists(){
        self.customAerialCategoryIndex = self.TVIdleScreenEntries!.categories.firstIndex { category in
            category.id == self.customAerialCategoryUUID
        } ?? -1

        if(self.customAerialCategoryIndex == -1){
            self._backupDefaultEntries()
            self._createCustomAerialCategory()
            return
        }
        self._updateCustomAerialCategorySubcategories()
    }
    
    private func _checkEntriesFileExists(){
        var isDir: ObjCBool = false
        if (!self.fileManager.fileExists(atPath: self.assetsURLCollection.customAssetsEntriesURL.path(), isDirectory: &isDir)){
            self._backupDefaultEntries()
        }
    }
    
    private func _createCustomAerialCategory(){
        let customEntryCategory = TVIdleScreenEntryCategory(
            id: self.customAerialCategoryUUID,
            preferredOrder: 5,
            previewImage: "",
            localizedNameKey: "Customized Aerial",
            representativeAssetID: "",
            localizedDescriptionKey: "Customized videos hacked by XTLi",
            subcategories: []
        )
        self.TVIdleScreenEntries?.categories.append(customEntryCategory)
        self.customAerialCategoryIndex = self.TVIdleScreenEntries!.categories.firstIndex { category in
            category.id == self.customAerialCategoryUUID
        } ?? -1
        _saveEntryChanges()
    }
    
    private func _addNewAerialAsset(newEntryAsset: TVIdleScreenEntryAsset, newSubcategory: TVIdleScreenEntryCategorySubcategory, originalAssetPath: String, originalAsserPreviewPath: String){
        let newAssetID = newEntryAsset.id
        do {
            try fileManager.copyItem(
                at: URL(fileURLWithPath: originalAssetPath),
                to: URL(fileURLWithPath: newEntryAsset.url4KSDR240FPS)
            )
            try fileManager.copyItem(
                at: URL(fileURLWithPath: originalAsserPreviewPath),
                to: URL(fileURLWithPath: newEntryAsset.previewImage)
            )
            self._copyItemWithCommand(from: URL(fileURLWithPath: originalAsserPreviewPath), to: self.assetsURLCollection.systemAssetsPreviewURL.appending(path: "asset-preview-\(newEntryAsset.id).jpg"))
            self._copyItemWithCommand(from: URL(fileURLWithPath: originalAssetPath), to: self.assetsURLCollection.systemAssetsVideoURL.appending(path: "4KSDR240FPS/\(newAssetID).mov"))
        } catch {
            print("Error when creat")
            print(error)
        }
        
        self.TVIdleScreenEntries?.assets.append(newEntryAsset)
        self.TVIdleScreenEntries?.categories[self.customAerialCategoryIndex].subcategories.append(newSubcategory)
        _saveEntryChanges()
    }
    
    private func _saveEntryChanges(){
        do {
            let encodedJSON = try JSONEncoder().encode(self.TVIdleScreenEntries)
            try encodedJSON.write(to: self.assetsURLCollection.customAssetsEntriesURL)
            self._copyItemWithCommand(from: self.assetsURLCollection.customAssetsEntriesURL, to: self.assetsURLCollection.systemAssetsEntriesURL)
        } catch {
            print(error)
        }
        self._updateCustomAerialCategorySubcategories()
    }
    
    private func _formatURLToCommandLineSafe(_ originalURL: URL) -> String{
        return originalURL.path(percentEncoded: false).replacingOccurrences(of: " ", with: "\\ ")
    }
    
    private func _copyItemWithCommand(from: URL, to: URL){
        let _from = self._formatURLToCommandLineSafe(from)
        let _to = self._formatURLToCommandLineSafe(to)
        self._runCommand(command: "sudo cp \(_from) \(_to)", requirePsssword: true)
    }
    
    private func _removeItemWithCommand(at: URL){
        let _at = self._formatURLToCommandLineSafe(at)
        self._runCommand(command: "sudo rm \(_at)", requirePsssword: true)
    }
    
    private func _runCommand(command: String, requirePsssword: Bool = false) -> Int{
        if (requirePsssword && self.userPassword == nil){
            return -1
        }
        let process: Process = Process()
        process.executableURL = URL(filePath: "/bin/bash")
        process.arguments = ["-c", command]
        
        print("running command \(command)")
        
        let inputPipe = Pipe()
        process.standardInput = inputPipe
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        
        process.launch()
        
        if (requirePsssword){
            inputPipe.fileHandleForWriting.write((self.userPassword?.data(using: .utf8))!)
        }
        
        process.waitUntilExit()
        if (process.terminationStatus != 0){
            return Int(process.terminationStatus)
        }
        return 0
    }
    
    func setUserPassword(password: String){
        self.userPassword = password
    }
    
    func getCustomAssetsRootURL() -> String{
        return self.assetsURLCollection.customAssetsRootURL.path(percentEncoded: false)
    }
    
    func getSystemAssetsVideoURL() -> String{
        return self.assetsURLCollection.systemAssetsVideoURL.path(percentEncoded: false)
    }
    
    func addNewScreenSaver(screenSaverName: String, screenSaverDescription: String, videoPath: String, videoPreviewPath: String, includeInShuffle: Bool){
        let assetID = UUID().uuidString
        let subcategoryID = UUID().uuidString
        
        let customAssetPath = self.assetsURLCollection.customAssetsVideoURL.appending(path: "\(assetID).mov").path(percentEncoded: false)
        let customAssetPreviewPath = self.assetsURLCollection.customAssetsPreviewURL.appending(path: "asset-preview-\(assetID).jpg").path(percentEncoded: false)
        
        let newEntryAsset = TVIdleScreenEntryAsset(
            localizedNameKey: screenSaverName,
            shotID: "",
            showInTopLevel: true,
            preferredOrder: 0,
            pointsOfInterest: Dictionary(),
            previewImage: customAssetPreviewPath,
            accessibilityLabel: screenSaverName,
            id: assetID,
            includeInShuffle: includeInShuffle,
            subcategories: [subcategoryID],
            categories: [self.customAerialCategoryUUID],
            url4KSDR240FPS: customAssetPath
        )
        let newSubcategory = TVIdleScreenEntryCategorySubcategory(
            previewImage: customAssetPreviewPath,
            preferredOrder: 0,
            representativeAssetID: assetID,
            id: subcategoryID,
            localizedNameKey: screenSaverName,
            localizedDescriptionKey: screenSaverDescription
        )
        
        self._addNewAerialAsset(newEntryAsset: newEntryAsset, newSubcategory: newSubcategory, originalAssetPath: videoPath, originalAsserPreviewPath: videoPreviewPath)
    }
    
    func deleteScreenSaver(id: String){
        self.TVIdleScreenEntries?.assets.removeAll(where: { asset in
            asset.id == id
        })
        self.TVIdleScreenEntries?.categories[self.customAerialCategoryIndex].subcategories.removeAll(where: { subcategory in
            subcategory.representativeAssetID == id
        })
        
        do {
            self._removeItemWithCommand(at: self.assetsURLCollection.systemAssetsVideoURL.appending(path: "4KSDR240FPS/\(id).mov"))
            self._removeItemWithCommand(at: self.assetsURLCollection.systemAssetsPreviewURL.appending(path: "asset-preview-\(id).jpg"))
            try self.fileManager.removeItem(at: self.assetsURLCollection.customAssetsVideoURL.appending(path: "\(id).mov"))
            try self.fileManager.removeItem(at: self.assetsURLCollection.customAssetsPreviewURL.appending(path: "asset-preview-\(id).jpg"))
        } catch {
            print(error)
        }

        self._saveEntryChanges()
    }
    
}
