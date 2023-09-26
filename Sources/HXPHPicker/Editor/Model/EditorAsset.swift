//
//  EditorAsset.swift
//  HXPHPicker
//
//  Created by Silence on 2023/5/17.
//

import UIKit
import AVFoundation

public struct EditorAsset {
    
    /// 编辑对象
    public let type: `Type`
    
    /// 编辑结果
    public var result: EditedResult?
    
    public init(type: `Type`, result: EditedResult? = nil) {
        self.type = type
        self.result = result
    }
}

extension EditorAsset {
    public enum `Type` {
        case none
        case image(UIImage)
        case imageData(Data)
        case video(URL)
        case videoAsset(AVAsset)
        case networkVideo(URL)
        #if canImport(Kingfisher)
        case networkImage(URL)
        #endif
        #if HXPICKER_ENABLE_PICKER
        case photoAsset(PhotoAsset)
        
        public var photoAsset: PhotoAsset? {
            switch self {
            case .photoAsset(let photoAsset):
                return photoAsset
            default:
                return nil
            }
        }
        #endif
         
        public var image: UIImage? {
            switch self {
            case .image(let image):
                return image
            default:
                return nil
            }
        }
        
        public var videoURL: URL? {
            switch self {
            case .video(let url):
                return url
            default:
                return nil
            }
        }
        
        public var networkVideoURL: URL? {
            switch self {
            case .networkVideo(let url):
                return url
            default:
                return nil
            }
        }
        
        #if canImport(Kingfisher)
        public var networkImageURL: URL? {
            switch self {
            case .networkImage(let url):
                return url
            default:
                return nil
            }
        }
        #endif
        
        public var contentType: EditorContentViewType {
            switch self {
            case .image(_), .imageData(_):
                return .image
            #if canImport(Kingfisher)
            case .networkImage(_):
                return .image
            #endif
            case .video(_), .networkVideo(_):
                return .video
            #if HXPICKER_ENABLE_PICKER
            case .photoAsset(let asset):
                return asset.mediaType == .photo ? .image : .video
            #endif
            default:
                return .unknown
            }
        }
    }
    
    public var contentType: EditorContentViewType {
        type.contentType
    }
}
