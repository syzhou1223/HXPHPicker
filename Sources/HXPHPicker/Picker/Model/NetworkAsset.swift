//
//  NetworkAsset.swift
//  HXPHPicker
//
//  Created by Slience on 2021/5/24.
//

import UIKit
#if canImport(Kingfisher)
import Kingfisher

public struct NetworkImageAsset: Codable {
    
    public enum loadMode: Codable {
        /// List: use the original image if the original image has a cache, use the thumbnail if there is no cache
        /// Large preview image: display the original image
        /// 列表：如果原图有缓存则使用原图，没有缓存则使用缩略图
        /// 预览大图：显示原图
        case varied
        
        /// If the original image is not cached, the thumbnail image will always be used, and the original image will not be actively loaded internally
        /// You can call loadNetworkOriginalImage() of the PhotoAsset object to load the original image
        /// 如果原图没有缓存则一直使用缩略图，内部不会主动加载原图
        /// 可以调用 PhotoAsset 对象的 loadNetworkOriginalImage() 加载原图
        case alwaysThumbnail
    }
    
    /// 网络图片下载时候的占位图
    public let placeholder: String?
    
    /// list cell display
    /// 缩略图，列表cell展示
    public let thumbnailURL: URL
    
    /// Size set by DownsamplingImageProcessor when Kingfisher downloads thumbnails
    /// .zero defaults to imageView.size
    /// Kingfisher 下载缩略图时 DownsamplingImageProcessor 设置的大小
    /// .zero 默认为 imageView.size
    public let thumbnailSize: CGSize
    
    /// Preview large image display
    /// 原图，预览大图展示
    public let originalURL: URL
    
    /// The way the list Cell loads pictures
    /// 列表Cell加载图片的方式
    public let thumbnailLoadMode: loadMode
    
    /// How to load images when previewing large images
    /// Call loadNetworkOriginalImage() of the PhotoAsset object to load the original image
    /// 预览大图时加载图片的方式
    /// 调用 PhotoAsset 对象的 loadNetworkOriginalImage() 加载原图
    public let originalLoadMode: loadMode
    
    /// Whether the display effect is fade in and fade out after the image is downloaded
    /// 图片下载完后显示效果是否为淡入淡出
    public let isFade: Bool
    
    /// size of the picture
    /// 图片尺寸
    public var imageSize: CGSize
    
    /// Image file size
    /// 图片文件大小
    public var fileSize: Int
    
    public init(
        thumbnailURL: URL,
        originalURL: URL,
        thumbnailLoadMode: loadMode = .alwaysThumbnail,
        originalLoadMode: loadMode = .varied,
        isFade: Bool = true,
        thumbnailSize: CGSize = .zero,
        placeholder: String? = nil,
        imageSize: CGSize = .zero,
        fileSize: Int = 0
    ) {
        self.thumbnailURL = thumbnailURL
        self.originalURL = originalURL
        self.thumbnailLoadMode = thumbnailLoadMode
        self.originalLoadMode = originalLoadMode
        self.isFade = isFade
        self.thumbnailSize = thumbnailSize
        self.placeholder = placeholder
        self.imageSize = imageSize
        self.fileSize = fileSize
    }
}
#endif

public struct NetworkVideoAsset {
    
    /// 网络视频地址
    public let videoURL: URL
    
    /// 视频时长
    public var duration: TimeInterval
    
    /// 视频封面，优先级大于 coverImageURL
    public var coverImage: UIImage?
    
    /// 图片文件大小
    public var fileSize: Int
    
    /// 视频尺寸
    public var videoSize: CGSize
    
    /// 封面的占位图
    public var coverPlaceholder: String?
    
    #if canImport(Kingfisher)
    /// 视频封面网络地址
    public var coverImageURL: URL?
    
    public init(
        videoURL: URL,
        duration: TimeInterval = 0,
        fileSize: Int = 0,
        coverImage: UIImage? = nil,
        videoSize: CGSize = .zero,
        coverImageURL: URL? = nil,
        coverPlaceholder: String? = nil
    ) {
        self.videoURL = videoURL
        self.duration = duration
        self.fileSize = fileSize
        self.coverImage = coverImage
        self.videoSize = videoSize
        self.coverImageURL = coverImageURL
        self.coverPlaceholder = coverPlaceholder
    }
    #else
    public init(
        videoURL: URL,
        duration: TimeInterval = 0,
        fileSize: Int = 0,
        coverImage: UIImage? = nil,
        videoSize: CGSize = .zero
    ) {
        self.videoURL = videoURL
        self.duration = duration
        self.fileSize = fileSize
        self.coverImage = coverImage
        self.videoSize = videoSize
    }
    #endif
}

extension NetworkVideoAsset: Codable {
    enum CodingKeys: CodingKey {
        case videoURL
        case duration
        case coverImage
        case fileSize
        case videoSize
        #if canImport(Kingfisher)
        case coverImageURL
        #endif
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        videoURL = try container.decode(URL.self, forKey: .videoURL)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        if let imageData = try container.decodeIfPresent(Data.self, forKey: .coverImage) {
            if #available(iOS 11.0, *) {
                coverImage = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIImage.self, from: imageData)
            }else {
                coverImage = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(imageData) as? UIImage
            }
        }else {
            coverImage = nil
        }
        fileSize = try container.decode(Int.self, forKey: .fileSize)
        videoSize = try container.decode(CGSize.self, forKey: .videoSize)
        #if canImport(Kingfisher)
        coverImageURL = try container.decodeIfPresent(URL.self, forKey: .coverImageURL)
        #endif
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(videoURL, forKey: .videoURL)
        try container.encode(duration, forKey: .duration)
        if let image = coverImage {
            if #available(iOS 11.0, *) {
                let imageData = try NSKeyedArchiver.archivedData(withRootObject: image, requiringSecureCoding: false)
                try container.encode(imageData, forKey: .coverImage)
            } else {
                let imageData = NSKeyedArchiver.archivedData(withRootObject: image)
                try container.encode(imageData, forKey: .coverImage)
            }
        }
        try container.encode(fileSize, forKey: .fileSize)
        try container.encode(videoSize, forKey: .videoSize)
        #if canImport(Kingfisher)
        try container.encode(coverImageURL, forKey: .coverImageURL)
        #endif
    }
}
