//
//  Core+URL.swift
//  HXPHPicker
//
//  Created by Slience on 2021/6/17.
//

import Foundation
#if canImport(Kingfisher)
import Kingfisher
#endif

extension URL: HXPickerCompatibleValue {
    var isGif: Bool {
        absoluteString.hasSuffix("gif") || absoluteString.hasSuffix("GIF")
    }
    var fileSize: Int {
        guard let fileSize = try? resourceValues(forKeys: [.fileSizeKey]) else {
            return 0
        }
        return fileSize.fileSize ?? 0
    }
    
    #if canImport(Kingfisher)
    var isCache: Bool {
        ImageCache.default.isCached(forKey: cacheKey)
    }
    #endif
    
    var fileType: FileType {
        guard let fileData = try? Data(contentsOf: self) else {
            return .unknown
        }
        return fileData.fileType
    }
}


public extension HXPickerWrapper where Base == URL {
    #if canImport(Kingfisher)
    var isCache: Bool {
        base.isCache
    }
    #endif
}
