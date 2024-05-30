//
//  BIMDataModel.swift
//  BIMDataViewer
//
//  Created by Armel Fardel on 12/01/2024.
//

import Foundation

protocol BIMDataModel {
    var ids: [Int] { get set }
    var projectId: Int { get set }
    var cloudId: Int { get set }
    var paramsJSONStringifiable: [String: Any] { get }
}

extension BIMDataModel {
    func paramsJSONStringified() -> String {
        do {
            let json = try JSONSerialization.data(withJSONObject: paramsJSONStringifiable)
            guard let jsonString = String(data: json, encoding: .utf8) else {
                // Should not happen
                print("Error while creating JSON for BIMData: not Stringifiable")
                return ""
            }
            return jsonString
        } catch {
            print("Error while creating JSON for BIMData: \(error)")
            return ""
        }
    }
}

struct BIMDataModelOffline: BIMDataModel {
    var ids: [Int]
    var projectId: Int
    var cloudId: Int
    let fileLocalPath: String
    
    var paramsJSONStringifiable: [String: Any] {
        ["projectId": projectId,
         "cloudId": cloudId,
         "modelIds": ids,
         "offline": [
            "enabled" : true,
            "dataFile": fileLocalPath
        ]]
    }
}

struct BIMDataModelOnline: BIMDataModel {
    var ids: [Int]
    var projectId: Int
    var cloudId: Int
    let accessToken: String
    
    var paramsJSONStringifiable: [String: Any] {
        ["projectId": projectId,
         "cloudId": cloudId,
         "modelIds": ids,
         "accessToken": accessToken]
    }
}

extension BIMDataModelOnline {
    static func defaultModel() -> BIMDataModel {
        BIMDataModelOnline(ids: [15097],
                           projectId: 237466,
                           cloudId: 10344,
                           accessToken: "TAbdyPzoQeYgVSMe4GUKoCEfYctVhcwJ")
    }
}

extension BIMDataModelOffline {
    static func defaultModel() -> BIMDataModel {
        let offlinePackage = Bundle.main.url(forResource: "offline-package",
                                             withExtension: "zip")!
        return BIMDataModelOffline(ids: [15097],
                                   projectId: 237466,
                                   cloudId: 10344,
                                   fileLocalPath: offlinePackage.absoluteString)
    }
}
