//
//  MoveFiles.swift
//  Customized Aerial Screen Saver
//
//  Created by Joel Tan on 19/12/2023.
//

import Foundation

func moveFilesIfFound() {
    // Move *files*
    let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first;
    
    guard let oldDirURL = appSupportURL?.appending(path: "com.xtl.customizedarealscreensaver") else { return };
    let newDirURL = appSupportURL?.appending(path: "com.xtl.customizedaerialscreensaver");
    
    if let contents = try? FileManager.default.contentsOfDirectory(at: oldDirURL, includingPropertiesForKeys: nil) {
        for fileURL in contents {
            let fileName = fileURL.lastPathComponent
            
            if let newFileURL = newDirURL?.appendingPathComponent(fileName) {
                do {
                    try FileManager.default.moveItem(at: fileURL, to: newFileURL)
                    print("Moved \(fileName) to \(newFileURL.path)")
                } catch {
                    print("Error moving \(fileName): \(error.localizedDescription)")
                }
            }
        }
    } else {
        print("Could not get the contents of the old directory.")
    }
    
    // Delete old dir
    do {
        try FileManager.default.removeItem(at: oldDirURL);
    }
    catch {
        print("Error Deleting Old Directory: \(error)")
    };
    
    // Update entries.json
    // ummmmmmm
}
