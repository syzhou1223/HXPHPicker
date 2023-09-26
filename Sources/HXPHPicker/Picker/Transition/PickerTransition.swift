//
//  HXPHPickerTransition.swift
//  HXPHPickerExample
//
//  Created by Silence on 2020/12/9.
//  Copyright © 2020 Silence. All rights reserved.
//

import UIKit
import Photos
#if canImport(Kingfisher)
import Kingfisher
#endif

public enum PickerTransitionType {
    case push
    case pop
    case present
    case dismiss
}

class PickerTransition: NSObject, UIViewControllerAnimatedTransitioning {
    let type: PickerTransitionType
    var requestID: PHImageRequestID?
    lazy var pushImageView: UIImageView = {
        let imageView = UIImageView.init()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    init(type: PickerTransitionType) {
        self.type = type
        super.init()
    }
    
    public func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if type == .dismiss {
            return 0.65
        }
        return 0.5
    }
    
    public func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning) {
        if type == .push || type == .pop {
            pushTransition(using: transitionContext)
        }else {
            presentTransition(using: transitionContext)
        }
    }
    // swiftlint:disable function_body_length
    func pushTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        // swiftlint:enable function_body_length
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(true)
            return
        }
        
        var previewVC: PhotoPreviewViewController?
        var pickerVC: PhotoPickerViewController?
        
        let containerView = transitionContext.containerView
        let contentView = UIView.init(frame: fromVC.view.bounds)
        if type == .push {
            pickerVC = fromVC as? PhotoPickerViewController
            previewVC = toVC as? PhotoPreviewViewController
        }else if type == .pop {
            pickerVC = toVC as? PhotoPickerViewController
            previewVC = fromVC as? PhotoPreviewViewController
        }
        guard let previewVC = previewVC else {
            transitionContext.completeTransition(true)
            return
        }

        let backgroundColor = PhotoManager.isDark ?
            previewVC.config.backgroundDarkColor :
            previewVC.config.backgroundColor
        
        let photoAsset = previewVC.photoAsset(for: previewVC.currentPreviewIndex)
         
        var fromView: UIView?
        var toView: UIView?
        
        if type == .push {
            containerView.addSubview(fromVC.view)
            containerView.addSubview(toVC.view)
            fromVC.view.insertSubview(contentView, at: 1)
            contentView.backgroundColor = backgroundColor.withAlphaComponent(0)
            contentView.addSubview(pushImageView)
            
            if let pickerVC = pickerVC, let photoAsset = photoAsset {
                if let cell = pickerVC.getCell(for: photoAsset) {
                    pushImageView.image = cell.photoView.image
                    pushImageView.frame = cell.photoView.convert(
                        cell.photoView.bounds,
                        to: containerView
                    )
                    fromView = cell
                }else {
                    pushImageView.center = CGPoint(x: toVC.view.width * 0.5, y: toVC.view.height * 0.5)
                }
                var reqeustAsset = photoAsset.phAsset != nil
                #if HXPICKER_ENABLE_EDITOR
                if photoAsset.editedResult != nil {
                    reqeustAsset = false
                }
                #endif
                if let phAsset = photoAsset.phAsset, reqeustAsset {
                    requestAssetImage(for: phAsset, isGIF: photoAsset.isGifAsset)
                }else if pushImageView.image == nil || photoAsset.isLocalAsset {
                    pushImageView.image = photoAsset.originalImage
                }
            }
            
            previewVC.collectionView.isHidden = true
            previewVC.bottomView.alpha = 0
            previewVC.view.backgroundColor = backgroundColor.withAlphaComponent(0)
        }else if type == .pop {
            containerView.addSubview(toVC.view)
            containerView.addSubview(fromVC.view)
            toVC.view.insertSubview(contentView, at: 1)
            contentView.backgroundColor = backgroundColor
            
            let cell = previewVC.getCell(for: previewVC.currentPreviewIndex)
            fromView = cell?.scrollContentView
            fromView?.frame = cell?.scrollContentView.convert(
                cell?.scrollContentView.bounds ?? CGRect.zero,
                to: containerView
            ) ?? CGRect.zero
            contentView.addSubview(fromView!)
            if let pickerVC = pickerVC, let photoAsset = photoAsset {
                toView = pickerVC.getCell(for: photoAsset)
                pickerVC.setCellLoadMode(.complete)
                if toView == nil {
                    pickerVC.scrollToCenter(for: photoAsset)
                    pickerVC.reloadCell(for: photoAsset)
                    DispatchQueue.main.async {
                        pickerVC.cellReloadImage()
                    }
                    toView = pickerVC.getCell(for: photoAsset)
                }else {
                    pickerVC.scrollCellToVisibleArea(toView as! PhotoPickerBaseViewCell)
                    DispatchQueue.main.async {
                        pickerVC.cellReloadImage()
                    }
                }
            }
            
            previewVC.collectionView.isHidden = true
            previewVC.view.backgroundColor = UIColor.clear
        }
        
        var rect: CGRect = .zero
        if type == .push {
            if UIDevice.isPad && photoAsset?.mediaType == .video {
                rect = PhotoTools.transformImageSize(
                    photoAsset?.imageSize ?? .zero,
                    toViewSize: toVC.view.size,
                    directions: [.horizontal]
                )
                if rect.width < toVC.view.width {
                    rect.origin.x = (toVC.view.width - rect.width) * 0.5
                }
                if rect.height < toVC.view.height {
                    rect.origin.y = (toVC.view.height - rect.height) * 0.5
                }
            }else {
                rect = PhotoTools.transformImageSize(
                    photoAsset?.imageSize ?? .zero,
                    to: toVC.view
                )
            }
            fromView?.isHidden = true
        }else if type == .pop {
            rect = toView?.convert(toView?.bounds ?? CGRect.zero, to: containerView) ?? .zero
            toView?.isHidden = true
        }
        var pickerShowParompt = false
        if AssetManager.authorizationStatusIsLimited() && pickerVC?.config.bottomView.isShowPrompt ?? false {
            pickerShowParompt = true
        }
        let pickerController = previewVC.pickerController
        let maskHeight = 50 + UIDevice.bottomMargin
        var previewShowSelectedView = false
        if let pickerController = pickerController,
           previewVC.config.bottomView.isShowSelectedView,
           pickerController.config.selectMode == .multiple {
            if pickerController.selectedAssetArray.isEmpty == false {
                previewShowSelectedView = true
                if !pickerShowParompt {
                    let maskY: CGFloat = type == .push ? 70 : 0
                    let maskHeight: CGFloat = type == .push ? 50 + UIDevice.bottomMargin : 120 + UIDevice.bottomMargin
                    let maskView = UIView(
                        frame: CGRect(
                            x: 0, y: maskY,
                            width: contentView.width, height: maskHeight
                        )
                    )
                    maskView.backgroundColor = .white
                    previewVC.bottomView.mask = maskView
                }
            }
        }
        if pickerShowParompt && !previewShowSelectedView {
            let maskY: CGFloat = type == .push ? 0 : 70
            let maskHeight: CGFloat = type == .push ? 120 + UIDevice.bottomMargin : 70 + UIDevice.bottomMargin
            let maskView = UIView.init(frame: CGRect(x: 0, y: maskY, width: contentView.width, height: maskHeight))
            maskView.backgroundColor = .white
            pickerVC?.bottomView.mask = maskView
        }
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration - 0.15) {
            if self.type == .push {
                contentView.backgroundColor = backgroundColor.withAlphaComponent(1)
            }else if self.type == .pop {
                contentView.backgroundColor = backgroundColor.withAlphaComponent(0)
            }
        }
        if type == .push {
            UIView.animate(withDuration: duration - 0.2, delay: 0, options: [.curveEaseIn]) {
                if previewVC.bottomView.mask != nil {
                    previewVC.bottomView.mask?.frame = CGRect(
                        x: 0, y: 0,
                        width: contentView.width, height: maskHeight + 70
                    )
                }
                if pickerVC?.bottomView.mask != nil {
                    pickerVC?.bottomView.mask?.frame = CGRect(x: 0, y: 70, width: contentView.width, height: maskHeight)
                }
            }
            let alphaDuration = previewVC.bottomView.mask == nil ? duration - 0.15 : 0.15
            UIView.animate(withDuration: alphaDuration) {
                previewVC.bottomView.alpha = 1
            }
        }else if type == .pop {
            UIView.animate(withDuration: duration - 0.2, delay: 0, options: [.curveLinear]) {
                if previewVC.bottomView.mask != nil {
                    previewVC.bottomView.mask?.frame = CGRect(
                        x: 0, y: 70,
                        width: contentView.width, height: maskHeight + 70
                    )
                }
                if pickerVC?.bottomView.mask != nil {
                    pickerVC?.bottomView.mask?.frame = CGRect(
                        x: 0, y: 0,
                        width: contentView.width, height: maskHeight + 70
                    )
                }
            }
            UIView.animate(withDuration: duration - 0.15, delay: 0.125, options: []) {
                previewVC.bottomView.alpha = 0
            }
        }
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: [.layoutSubviews, .curveEaseOut]
        ) {
            if self.type == .push {
                self.pushImageView.frame = rect
            }else if self.type == .pop {
                if rect.isEmpty {
                    fromView?.transform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
                    fromView?.alpha = 0
                }else {
                    fromView?.frame = rect
                }
            }
            if let picker = pickerVC?.pickerController {
                picker.pickerDelegate?
                    .pickerController(picker, animateTransition: self.type)
            }
        } completion: { (isFinished) in
            pickerVC?.bottomView.mask = nil
            previewVC.bottomView.mask = nil
            if self.type == .push {
                if let requestID = self.requestID {
                    PHImageManager.default().cancelImageRequest(requestID)
                    self.requestID = nil
                }
                fromView?.isHidden = false
                previewVC.setCurrentCellImage(image: self.pushImageView.image)
                previewVC.collectionView.isHidden = false
                previewVC.configColor()
                self.pushImageView.removeFromSuperview()
                contentView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }else if self.type == .pop {
                toView?.isHidden = false
                UIView.animate(
                    withDuration: 0.25,
                    delay: 0,
                    options: [.allowUserInteraction]) {
                    fromView?.alpha = 0
                } completion: { (isFinished) in
                    contentView.removeFromSuperview()
                    transitionContext.completeTransition(true)
                }
            }
        }
    }
    // swiftlint:disable function_body_length
    func presentTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        // swiftlint:enable function_body_length
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(true)
            return
        }
        
        let containerView = transitionContext.containerView
        let contentView = UIView()
        
        var pickerController: PhotoPickerController
        if type == .present {
            pickerController = toVC as! PhotoPickerController
        }else {
            pickerController = fromVC as! PhotoPickerController
        }
        let backgroundColor = PhotoManager.isDark ?
            pickerController.config.previewView.backgroundDarkColor :
            pickerController.config.previewView.backgroundColor
        var fromView: UIView
        var previewView: UIView?
        var toRect: CGRect = .zero
        let previewViewController = pickerController.previewViewController
        if type == .present {
            contentView.frame = toVC.view.bounds
            containerView.addSubview(contentView)
            containerView.addSubview(toVC.view)
            contentView.backgroundColor = backgroundColor.withAlphaComponent(0)
            previewViewController?.view.backgroundColor = backgroundColor.withAlphaComponent(0)
            pickerController.view.backgroundColor = nil
            pickerController.navigationBar.alpha = 0
            previewViewController?.bottomView.alpha = 0
            previewViewController?.collectionView.isHidden = true
            fromView = pushImageView
            let currentPreviewIndex = previewViewController?.currentPreviewIndex ?? 0
            if let view = pickerController.pickerDelegate?.pickerController(
                pickerController,
                presentPreviewViewForIndexAt: currentPreviewIndex) {
                let rect = view.convert(view.bounds, to: contentView)
                fromView.frame = rect
                if view.layer.cornerRadius > 0 {
                    pushImageView.layer.cornerRadius = view.layer.cornerRadius
                    pushImageView.layer.masksToBounds = true
                }
                previewView = view
            }else if let rect = pickerController.pickerDelegate?.pickerController(
                        pickerController,
                        presentPreviewFrameForIndexAt: currentPreviewIndex),
                     !rect.equalTo(.zero) {
                fromView.frame = rect
            }else {
                fromView.center = CGPoint(x: toVC.view.width * 0.5, y: toVC.view.height * 0.5)
            }
            
            if let image = pickerController.pickerDelegate?.pickerController(
                pickerController,
                presentPreviewImageForIndexAt: currentPreviewIndex) {
                pushImageView.image = image
            }
            var photoAsset: PhotoAsset?
            if pickerController.isExternalPickerPreview {
                photoAsset = pickerController.previewViewController?.photoAsset(for: currentPreviewIndex)
            }else if !pickerController.selectedAssetArray.isEmpty {
                photoAsset = pickerController.selectedAssetArray[currentPreviewIndex]
            }else {
                photoAsset = pickerController.previewViewController?.photoAsset(for: currentPreviewIndex)
            }
            
            if let photoAsset = photoAsset {
                var reqeustAsset = photoAsset.phAsset != nil
                #if HXPICKER_ENABLE_EDITOR
                if photoAsset.editedResult != nil {
                    reqeustAsset = false
                }
                #endif
                if let phAsset = photoAsset.phAsset, reqeustAsset {
                    requestAssetImage(for: phAsset, isGIF: photoAsset.isGifAsset)
                }else if pushImageView.image == nil || photoAsset.isLocalAsset {
                    if let image = photoAsset.originalImage {
                        pushImageView.image = image
                    }
                }
                #if canImport(Kingfisher)
                if let networkImage = photoAsset.networkImageAsset {
                    let cacheKey = networkImage.originalURL.cacheKey
                    if ImageCache.default.isCached(forKey: cacheKey) {
                        ImageCache.default.retrieveImage(
                            forKey: cacheKey,
                            options: [],
                            callbackQueue: .mainAsync
                        ) { [weak self] in
                            guard let self = self else { return }
                            switch $0 {
                            case .success(let value):
                                if let image = value.image, self.pushImageView.superview != nil {
                                    self.pushImageView.setImage(image, duration: 0.4, animated: true)
                                }
                            default:
                                break
                            }
                        }
                    }else {
                        let cacheKey = networkImage.thumbnailURL.cacheKey
                        if ImageCache.default.isCached(forKey: cacheKey) {
                            ImageCache.default.retrieveImage(
                                forKey: cacheKey,
                                options: [],
                                callbackQueue: .mainAsync
                            ) { [weak self] in
                                guard let self = self else { return }
                                switch $0 {
                                case .success(let value):
                                    if let image = value.image,
                                       self.pushImageView.superview != nil {
                                        self.pushImageView.setImage(image, duration: 0.4, animated: true)
                                    }
                                default:
                                    break
                                }
                            }
                        }
                    }
                }
                #endif
                if UIDevice.isPad && photoAsset.mediaType == .video {
                    toRect = PhotoTools.transformImageSize(
                        photoAsset.imageSize,
                        toViewSize: toVC.view.size,
                        directions: [.horizontal]
                    )
                }else {
                    toRect = PhotoTools.transformImageSize(photoAsset.imageSize, to: toVC.view)
                }
            }
        }else {
            contentView.frame = fromVC.view.bounds
            previewViewController?.view.insertSubview(contentView, at: 0)
            previewViewController?.view.backgroundColor = .clear
            previewViewController?.collectionView.isHidden = true
            pickerController.view.backgroundColor = .clear
            contentView.backgroundColor = backgroundColor
            let currentPreviewIndex = previewViewController?.currentPreviewIndex ?? 0
            var hasCornerRadius = false
            if let view = pickerController.pickerDelegate?.pickerController(
                pickerController,
                dismissPreviewViewForIndexAt: currentPreviewIndex) {
                toRect = view.convert(view.bounds, to: containerView)
                previewView = view
                if view.layer.cornerRadius > 0 {
                    hasCornerRadius = true
                }
            }else if let rect = pickerController.pickerDelegate?.pickerController(
                        pickerController,
                        dismissPreviewFrameForIndexAt: currentPreviewIndex),
                     !rect.equalTo(.zero) {
                toRect = rect
            }
            if let previewVC = previewViewController,
               let cell = previewVC.getCell(for: previewVC.currentPreviewIndex),
               let cellContentView = cell.scrollContentView {
                cellContentView.hiddenOtherSubview()
                fromView = cellContentView
                fromView.frame = cellContentView.convert(cellContentView.bounds, to: containerView)
            }else {
                fromView = pushImageView
            }
            
            if hasCornerRadius {
                fromView.layer.masksToBounds = true
            }
        }
        if let photoBrowser = pickerController as? PhotoBrowser {
            if photoBrowser.hideSourceView {
                previewView?.isHidden = true
            }
        }else {
            previewView?.isHidden = true
        }
        contentView.addSubview(fromView)
        let duration = (self.type == .dismiss && !toRect.isEmpty) ?
            transitionDuration(using: transitionContext) - 0.2 :
            transitionDuration(using: transitionContext)
        let colorDuration = duration - 0.15
        let colorDelay = type == .present ? 0.05 : 0
        UIView.animate(withDuration: colorDuration, delay: colorDelay, options: [ .curveLinear]) {
            if self.type == .present {
                previewViewController?.bottomView.alpha = 1
                contentView.backgroundColor = backgroundColor.withAlphaComponent(1)
            }else if self.type == .dismiss {
                previewViewController?.bottomView.alpha = 0
                contentView.backgroundColor = backgroundColor.withAlphaComponent(0)
            }
        }
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: [.layoutSubviews, .curveEaseOut]
        ) {
            if self.type == .present {
                pickerController.navigationBar.alpha = 1
                if self.pushImageView.layer.cornerRadius > 0 {
                    self.pushImageView.layer.cornerRadius = 0
                }
                self.pushImageView.frame = toRect
            }else if self.type == .dismiss {
                pickerController.navigationBar.alpha = 0
                if let previewView = previewView, previewView.layer.cornerRadius > 0 {
                    fromView.layer.cornerRadius = previewView.layer.cornerRadius
                }
                if toRect.isEmpty {
                    fromView.transform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
                    fromView.alpha = 0
                }else {
                    fromView.frame = toRect
                }
            }
            pickerController.pickerDelegate?
                .pickerController(pickerController, animateTransition: self.type)
        } completion: { (isFinished) in
            previewView?.isHidden = false
            if self.type == .present {
                if let requestID = self.requestID {
                    PHImageManager.default().cancelImageRequest(requestID)
                    self.requestID = nil
                }
                let currentPreviewIndex = previewViewController?.currentPreviewIndex ?? 0
                pickerController.pickerDelegate?.pickerController(
                    pickerController,
                    previewPresentComplete: currentPreviewIndex
                )
                previewViewController?.view.backgroundColor = backgroundColor.withAlphaComponent(1)
                previewViewController?.setCurrentCellImage(image: self.pushImageView.image)
                previewViewController?.collectionView.isHidden = false
                previewViewController?.configColor()
                pickerController.configBackgroundColor()
                self.pushImageView.removeFromSuperview()
                contentView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }else {
                let currentPreviewIndex = previewViewController?.currentPreviewIndex ?? 0
                pickerController.pickerDelegate?.pickerController(
                    pickerController,
                    previewDismissComplete: currentPreviewIndex
                )
                if toRect.isEmpty {
                    contentView.removeFromSuperview()
                    transitionContext.completeTransition(true)
                }else {
                    UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction]) {
                        fromView.alpha = 0
                    } completion: { (isFinished) in
                        contentView.removeFromSuperview()
                        transitionContext.completeTransition(true)
                    }
                }
            }
        }
    }
    
    func requestAssetImage(for asset: PHAsset, isGIF: Bool = false) {
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        options.deliveryMode = .fastFormat
        requestID = AssetManager.requestImageData(
            for: asset,
            options: options
        ) {
            var info: [AnyHashable: Any]?
            switch $0 {
            case .success(let dataResult):
                info = dataResult.info
                DispatchQueue.global().async {
                    var image: UIImage?
                    let dataCount = CGFloat(dataResult.imageData.count)
                    if !AssetManager.assetIsDegraded(for: info) &&
                        dataCount > 1000000 && !isGIF {
                        if let imageData = PhotoTools.imageCompress(
                            dataResult.imageData,
                            compressionQuality: dataCount.transitionCompressionQuality
                        ) {
                            image = UIImage(data: imageData)?.normalizedImage()
                        }
                    }else {
                        if dataResult.imageOrientation != .up {
                            image = UIImage(data: dataResult.imageData)?.normalizedImage()
                        }else {
                            image = UIImage(data: dataResult.imageData)
                        }
                    }
                    DispatchQueue.main.async {
                        if self.pushImageView.superview != nil {
                            self.pushImageView.image = image
                        }
                    }
                }
            case .failure(let error):
                info = error.info
            }
            if AssetManager.assetDownloadFinined(for: info) ||
                AssetManager.assetCancelDownload(for: info) {
                self.requestID = nil
            }
        }
    }
}
