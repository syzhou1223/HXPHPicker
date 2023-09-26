//
//  AssetManager+ImageURL.swift
//  HXPHPicker
//
//  Created by Slience on 2021/1/8.
//

import UIKit
import Photos

// MARK: 获取图片地址
public extension AssetManager {
    typealias ImageURLResultHandler = (Result<URL, AssetError>) -> Void
    
    /// 请求获取图片地址
    /// - Parameters:
    ///   - asset: 对应的 PHAsset 数据
    ///   - resultHandler: 获取结果
    static func requestImageURL(
        for asset: PHAsset,
        resultHandler: @escaping ImageURLResultHandler
    ) {
        requestImageURL(
            for: asset,
            suffix: "png",
            resultHandler: resultHandler
        )
    }
    
    /// 请求获取图片地址
    /// - Parameters:
    ///   - asset: 对应的 PHAsset 数据
    ///   - suffix: 后缀格式
    ///   - resultHandler: 获取结果
    static func requestImageURL(
        for asset: PHAsset,
        suffix: String,
        resultHandler: @escaping ImageURLResultHandler
    ) {
        let imageURL = PhotoTools.getTmpURL(for: suffix)
        requestImageURL(
            for: asset,
            toFile: imageURL,
            resultHandler: resultHandler
        )
    }
    
    /// 获取原始图片地址
    /// - Parameters:
    ///   - asset: 对应的 PHAsset 数据
    ///   - fileURL: 指定本地地址
    ///   - isOriginal: 是否获取系统相册最原始的数据，如果在系统相册编辑过，则获取的是未编辑的图片
    ///   - resultHandler: 获取结果   
    static func requestImageURL(
        for asset: PHAsset,
        toFile fileURL: URL,
        isOriginal: Bool = false,
        resultHandler: @escaping ImageURLResultHandler
    ) {
        var imageResource: PHAssetResource?
        var resources: [PHAssetResourceType: PHAssetResource] = [:]
        for resource in PHAssetResource.assetResources(for: asset) {
            resources[resource.type] = resource
        }
        if isOriginal {
            if let resource = resources[.photo] {
                imageResource = resource
            }else if let resource = resources[.fullSizePhoto] {
                imageResource = resource
            }
        }else {
            if let resource = resources[.fullSizePhoto] {
                imageResource = resource
            }else if let resource = resources[.photo] {
                imageResource = resource
            }
        }
        guard let imageResource = imageResource else {
            resultHandler(.failure(.assetResourceIsEmpty))
            return
        }
        if !PhotoTools.removeFile(fileURL: fileURL) {
            resultHandler(.failure(.removeFileFailed))
            return
        }
        let imageURL = fileURL
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = true
        PHAssetResourceManager.default().writeData(
            for: imageResource,
            toFile: imageURL,
            options: options
        ) { error in
            DispatchQueue.main.async {
                if let error = error {
                    resultHandler(.failure(.assetResourceWriteDataFailed(error)))
                }else {
                    resultHandler(.success(imageURL))
                }
            }
        }
    }
    
    /// 请求获取图片地址
    /// - Parameters:
    ///   - asset: 对应的 PHAsset 数据
    ///   - resultHandler: 获取结果
    /// - Returns: 请求ID
    @discardableResult
    static func requestImageURL(
        for asset: PHAsset,
        resultHandler: @escaping (URL?, UIImage?) -> Void
    ) -> PHContentEditingInputRequestID {
        let options = PHContentEditingInputRequestOptions.init()
        options.isNetworkAccessAllowed = true
        return asset.requestContentEditingInput(
            with: options
        ) { (input, info) in
            DispatchQueue.main.async {
                resultHandler(
                    input?.fullSizeImageURL,
                    input?.displaySizeImage
                )
            }
        }
    }
}
