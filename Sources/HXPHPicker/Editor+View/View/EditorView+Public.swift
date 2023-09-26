//
//  EditorView+Public.swift
//  HXPHPicker
//
//  Created by Slience on 2022/11/12.
//

import UIKit
import AVFoundation

public extension EditorView {
    
    /// 当前视图状态
    var state: State {
        get { editState }
        set {
            if newValue == .edit {
                startEdit(false)
            }else {
                cancelEdit(false)
            }
        }
    }
    
    /// 当前编辑的类型
    var type: EditorContentViewType {
        adjusterView.contentType
    }
    
    /// 编辑的图片
    private(set) var image: UIImage? {
        get { adjusterView.image }
        set { adjusterView.setImage(newValue) }
    }
    
    /// 设置 image
    /// 每次都会重置编辑状态
    func setImage(_ image: UIImage?) {
        resetState()
        self.image = image
        setContent()
        adjusterView.updateVideoController()
    }
    
    /// 更新 image
    /// 如果图片的宽高比不一致会重置编辑状态
    func updateImage(_ image: UIImage?) {
        var updateScale = false
        if let image = image, let lastImage = self.image {
            let scale = CGFloat(Int(image.width / image.height * 1000)) / 1000
            let lastScale = CGFloat(Int(lastImage.width / lastImage.height * 1000)) / 1000
            updateScale = scale != lastScale
        }
        if updateScale {
            resetState()
        }
        self.image = image
        if updateScale {
            setContent()
        }
        adjusterView.updateVideoController()
    }
    
    /// 设置 imageData
    /// 支持gif
    func setImageData(_ imageData: Data?) {
        resetState()
        adjusterView.setImageData(imageData)
        setContent()
        adjusterView.updateVideoController()
    }
    
    /// 设置 AVAsset
    /// - Parameters:
    ///   - avAsset: 对应的 AVAsset 对象
    ///   - coverImage: 视频封面图片，在没加载视频之前显示
    func setAVAsset(_ avAsset: AVAsset, coverImage: UIImage? = nil) {
        resetState()
        adjusterView.setVideoAsset(avAsset, coverImage: coverImage)
        setContent()
        adjusterView.updateVideoController()
    }
    
    var avAsset: AVAsset? {
        adjusterView.avAsset
    }
    
    /// 获取当前编辑数据
    var adjustmentData: EditAdjustmentData {
        adjusterView.getData()
    }
    
    /// 设置编辑数据
    func setAdjustmentData(_ data: EditAdjustmentData?) {
        guard let data = data else {
            return
        }
        if layoutContent {
            adjusterView.isHidden = true
            operates.insert(.setData(data), at: 0)
            return
        }
        if reloadContent {
            adjusterView.isHidden = true
            reloadOperates.insert(.setData(data), at: 0)
            return
        }
        if !data.content.editSize.equalTo(.zero) {
            editSize = data.content.editSize
        }
        updateEditSize()
        updateContentSize()
        adjusterView.setData(data)
        if editState == .normal {
            setCustomMaskFrame(false)
        }
        adjusterView.isHidden = false
    }
    
    /// 加载视频
    /// - Parameters:
    ///   - isPlay: 加载成功之后是否播放视频
    ///   - completion: 加载完成
    func loadVideo(isPlay: Bool, _ completion: ((Bool) -> Void)? = nil) {
        adjusterView.loadVideoAsset(isPlay: isPlay, completion)
    }
    
    
    /// 视频是否正在播放
    var isVideoPlaying: Bool {
        adjusterView.isVideoPlaying
    }
    
    /// 视频时长
    var videoDuration: CMTime {
        adjusterView.videoDuration
    }
    
    /// 视频当前播放时间
    var videoPlayTime: CMTime {
        adjusterView.videoPlayTime
    }
    
    /// 视频开始播放的时间
    /// 作用于视频进度条的显示
    var videoStartTime: CMTime? {
        get { adjusterView.videoStartTime }
        set { adjusterView.videoStartTime = newValue }
    }
    
    /// 视频结束播放的时间
    /// 作用于视频进度条的显示
    var videoEndTime: CMTime? {
        get { adjusterView.videoEndTime }
        set { adjusterView.videoEndTime = newValue }
    }
    
    /// 调整视频播放时间
    func seekVideo(to time: CMTime, isPlay: Bool = false, comletion: ((Bool) -> Void)? = nil) {
        adjusterView.seekVideo(to: time, isPlay: isPlay, comletion: comletion)
    }
    
    func seekVideo(to time: TimeInterval, isPlay: Bool, comletion: ((Bool) -> Void)? = nil) {
        adjusterView.seekVideo(to: time, isPlay: isPlay, comletion: comletion)
    }
    
    /// 视频音量
    var videoVolume: CGFloat {
        get { adjusterView.videoVolume }
        set { adjusterView.videoVolume = newValue }
    }
    
    /// 播放视频
    func playVideo() {
        adjusterView.playVideo()
    }
    
    /// 暂停视频
    func pauseVideo() {
        adjusterView.pauseVideo()
    }
    
    /// 视频自动循环播放
    var isVideoPlayToEndTimeAutoPlay: Bool {
        get { adjusterView.isVideoPlayToEndTimeAutoPlay}
        set { adjusterView.isVideoPlayToEndTimeAutoPlay = newValue }
    }
    
    /// 重置视频播放时间
    func resetPlayVideo(completion: ((CMTime) -> Void)? = nil) {
        adjusterView.resetPlayVideo(completion: completion)
    }
    
    /// 显示视频控制条，编辑状态下无效
    func showVideoControl(_ animated: Bool) {
        adjusterView.showVideoControl(animated)
    }
    
    /// 隐藏视频控制条，编辑状态下无效
    func hideVideoControl(_ animated: Bool) {
        adjusterView.hideVideoControl(animated)
    }
    
    var finalView: UIView {
        adjusterView.finalView
    }
    
    var contentView: UIView {
        adjusterView
    }
}

// MARK: 绘画
public extension EditorView {
    
    /// 绘画功能，编辑状态下无法开启
    /// 进入编辑模式会自动关闭，结束编辑后需要手动开启
    var isDrawEnabled: Bool {
        get { adjusterView.isDrawEnabled }
        set { adjusterView.isDrawEnabled = newValue }
    }
    
    /// 画笔宽度，默认 5
    var drawLineWidth: CGFloat {
        get { adjusterView.drawLineWidth }
        set { adjusterView.drawLineWidth = newValue }
    }
    
    /// 画笔颜色，默认白色
    var drawLineColor: UIColor {
        get { adjusterView.drawLineColor }
        set { adjusterView.drawLineColor = newValue }
    }
    
    /// 绘画是否可以撤销
    var isCanUndoDraw: Bool {
        adjusterView.isCanUndoDraw
    }
    
    /// 撤销上一次的绘画
    func undoDraw() {
        adjusterView.undoDraw()
    }
    
    /// 撤销所有绘画
    func undoAllDraw() {
        adjusterView.undoAllDraw()
    }
}

// MARK: 马赛克涂抹
//  视频不支持马赛克涂抹
public extension EditorView {
    
    /// 马赛克图片
    var mosaicImage: UIImage? {
        get { adjusterView.mosaicOriginalImage }
        set { adjusterView.mosaicOriginalImage = newValue }
    }
    
    var mosaicCGImage: CGImage? {
        get { adjusterView.mosaicOriginalCGImage }
        set { adjusterView.mosaicOriginalCGImage = newValue }
    }
    
    /// 马赛克涂抹功能，编辑状态下无法开启
    /// 使用马赛克涂抹之前请先设置马赛克图片
    /// 进入编辑模式会自动关闭，结束编辑后需要手动开启
    var isMosaicEnabled: Bool {
        get { adjusterView.isMosaicEnabled }
        set { adjusterView.isMosaicEnabled = newValue }
    }
    
    /// 马赛克宽度，默认 25
    var mosaicWidth: CGFloat {
        get { adjusterView.mosaicWidth }
        set { adjusterView.mosaicWidth = newValue }
    }
    
    /// 涂抹宽度， 默认 30
    var smearWidth: CGFloat {
        get { adjusterView.smearWidth }
        set { adjusterView.smearWidth = newValue }
    }
    
    /// 马赛克涂抹类型，默认 马赛克
    var mosaicType: EditorMosaicType {
        get { adjusterView.mosaicType }
        set { adjusterView.mosaicType = newValue }
    }
    
    /// 是否可以撤销
    var isCanUndoMosaic: Bool {
        adjusterView.isCanUndoMosaic
    }
    
    /// 撤销上一次的马赛克涂抹
    func undoMosaic() {
        adjusterView.undoMosaic()
    }
    
    /// 撤销所有马赛克涂抹
    func undoAllMosaic() {
        adjusterView.undoAllMosaic()
    }
}

public extension EditorView {
    
    /// 是否允许拖动贴图
    /// 进入编辑模式会自动关闭，结束编辑后需要手动开启 
    var isStickerEnabled: Bool {
        get { adjusterView.isStickerEnabled }
        set { adjusterView.isStickerEnabled = newValue }
    }
    
    /// 贴图数量
    var stickerCount: Int {
        adjusterView.stickerCount
    }
    
    /// 拖动贴图时，是否显示删除View
    var isStickerShowTrash: Bool {
        get { adjusterView.isStickerShowTrash }
        set { adjusterView.isStickerShowTrash = newValue }
    }
    
    /// 添加贴图
    @discardableResult
    func addSticker(
        _ image: UIImage,
        isSelected: Bool = false
    ) -> EditorStickersItemBaseView {
        adjusterView.addSticker(.init(.image(image)), isSelected: isSelected)
    }
    
    /// 添加贴图，支持GIF
    @discardableResult
    func addSticker(
        _ imageData: Data,
        isSelected: Bool = false
    ) -> EditorStickersItemBaseView {
        adjusterView.addSticker(.init(.imageData(imageData)), isSelected: isSelected)
    }
    
    /// 添加文本贴纸
    @discardableResult
    func addSticker(
        _ text: EditorStickerText,
        isSelected: Bool = false
    ) -> EditorStickersItemBaseView {
        adjusterView.addSticker(.init(.text(text)), isSelected: isSelected)
    }
    
    /// 添加音频贴纸
    @discardableResult
    func addSticker(
        _ audio: EditorStickerAudio,
        isSelected: Bool = false
    ) -> EditorStickersItemBaseView {
        adjusterView.addSticker(.init(.audio(audio)), isSelected: isSelected)
    }
    
    /// 添加贴纸
    @discardableResult
    func addSticker(
        _ type: EditorStickerItemType,
        isSelected: Bool = false
    ) -> EditorStickersItemBaseView {
        adjusterView.addSticker(.init(type), isSelected: isSelected)
    }
    
    /// 移除指定贴纸
    /// - Parameter itemView: 对应的贴纸视图
    func removeSticker(at itemView: EditorStickersItemBaseView) {
        adjusterView.removeSticker(at: itemView)
    }
    
    /// 移除所有贴纸
    func removeAllSticker() {
        adjusterView.removeAllSticker()
    }
    
    /// 更新文字贴图
    func updateSticker(
        _ text: EditorStickerText
    ) {
        adjusterView.updateSticker(text)
    }
    
    /// 取消当前选中的贴纸
    func deselectedSticker() {
        adjusterView.deselectedSticker()
    }
    
    /// 显示贴图视图
    func showStickersView() {
        adjusterView.showStickersView()
    }
    
    /// 隐藏贴图视图
    func hideStickersView() {
        adjusterView.hideStickersView()
    }
}

// MARK: 自定义遮罩
public extension EditorView {
    
    /// 遮罩类型
    var maskType: MaskType {
        get {
            adjusterView.maskType
        }
        set {
            setMaskType(newValue, animated: false)
        }
    }
    
    /// 设置遮罩类型
    func setMaskType(_ maskType: EditorView.MaskType, animated: Bool) {
        adjusterView.setMaskType(maskType, animated: animated)
    }
    
    /// 蒙版图片
    var maskImage: UIImage? {
        get {
            adjusterView.maskImage
        }
        set {
            setMaskImage(newValue, animated: false)
        }
    }
    
    /// 设置蒙版图片
    func setMaskImage(_ image: UIImage?, animated: Bool) {
        adjusterView.setMaskImage(image, animated: animated)
    }
}

// MARK: 编辑调整
public extension EditorView {
    
    /// 原始宽高比
    var originalAspectRatio: CGSize {
        adjusterView.originalAspectRatio
    }
    
    /// 是否显示比例大小
    var isShowScaleSize: Bool {
        get { adjusterView.isShowScaleSize }
        set { adjusterView.isShowScaleSize = newValue }
    }
    
    /// 重置时是否忽略固定比例的设置（默认：true）
    /// true    重置到原始比例
    /// false   重置到当前比例的中心位置
    var isResetIgnoreFixedRatio: Bool {
        get { adjusterView.isResetIgnoreFixedRatio }
        set { adjusterView.isResetIgnoreFixedRatio = newValue }
    }
    
    /// 初始编辑时的裁剪框比例
    var initialAspectRatio: CGSize {
        get { adjusterView.initialAspectRatio }
        set { adjusterView.initialAspectRatio = newValue }
    }
    
    /// 初始编辑时固定裁剪框
    var initialFixedRatio: Bool {
        get { adjusterView.initialFixedRatio }
        set { adjusterView.initialFixedRatio = newValue }
    }
    
    /// 初始编辑时圆形裁剪框
    /// isResetIgnoreFixedRatio = false，可以避免重置时恢复原始宽高
    var initialRoundMask: Bool {
        get { adjusterView.initialRoundMask }
        set { adjusterView.initialRoundMask = newValue }
    }
    
    /// 固定裁剪框比例
    var isFixedRatio: Bool {
        get { adjusterView.isFixedRatio }
        set { adjusterView.isFixedRatio = newValue }
    }
    
    /// 当前裁剪框比例
    var aspectRatio: CGSize {
        get { adjusterView.currentAspectRatio }
        set { setAspectRatio(newValue, animated: false)}
    }
    
    /// 当前比例是否为原始比例
    var isOriginalRatio: Bool {
        adjusterView.isOriginalRatio
    }
    
    /// 设置裁剪框比例
    func setAspectRatio(_ ratio: CGSize, animated: Bool) {
        adjusterView.setAspectRatio(ratio, animated: animated)
    }
    
    /// 是否圆形裁剪框
    var isRoundMask: Bool {
        get { adjusterView.isRoundMask }
        set { setRoundMask(newValue, animated: false) }
    }
    
    /// 设置圆形裁剪框
    func setRoundMask(_ isRound: Bool, animated: Bool) {
        if layoutContent {
            operates.append(.setRoundMask(isRound))
            return
        }
        if reloadContent {
            reloadOperates.append(.setRoundMask(isRound))
            return
        }
        if isRoundMask == isRound {
            return
        }
        if isRound {
            setMaskImage(nil, animated: animated)
            isFixedRatio = true
            adjusterView.isRoundMask = true
            adjusterView.setAspectRatio(.init(width: 1, height: 1), resetRound: false, animated: animated)
        }else {
            isFixedRatio = false
            setAspectRatio(.init(width: 1, height: 1), animated: animated)
        }
    }
    
    func resetZoom(
        _ animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        resetZoomScale(animated, completion: completion)
    }
    
    /// 开始编辑
    func startEdit(
        _ animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        if editState == .edit {
            return
        }
        if layoutContent {
            operates.append(.startEdit(completion))
            return
        }
        if reloadContent {
            reloadOperates.append(.startEdit(completion))
            return
        }
        editState = .edit
        isScrollEnabled = false
        resetZoomScale(animated)
        setCustomMaskFrame(true)
        adjusterView.startEdit(animated) { [weak self] in
            guard let self = self else { return }
            self.adjusterView.zoomScale = self.zoomScale
            completion?()
        }
    }
    
    /// 完成编辑
    func finishEdit(
        _ animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        if editState == .normal {
            return
        }
        if layoutContent {
            operates.append(.finishEdit(completion))
            return
        }
        if reloadContent {
            reloadOperates.append(.finishEdit(completion))
            return
        }
        editState = .normal
        isScrollEnabled = true
        resetZoomScale(animated)
        adjusterView.finishEdit(animated) { [weak self] in
            guard let self = self else { return }
            self.adjusterView.zoomScale = self.zoomScale
            completion?()
        }
        editSize = adjusterView.editSize
        updateContentSize()
        setCustomMaskFrame(false)
    }
    
    /// 取消编辑
    func cancelEdit(
        _ animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        if editState == .normal {
            return
        }
        if layoutContent {
            operates.append(.cancelEdit(completion))
            return
        }
        if reloadContent {
            reloadOperates.append(.cancelEdit(completion))
            return
        }
        editState = .normal
        isScrollEnabled = true
        resetZoomScale(animated)
        adjusterView.cancelEdit(animated) { [weak self] in
            guard let self = self else { return }
            self.adjusterView.zoomScale = self.zoomScale
            completion?()
        }
        setCustomMaskFrame(false)
    }
    
    /// 控制画笔、贴图...导出之后清晰程度
    var exportScale: CGFloat {
        get { adjusterView.exportScale }
        set { adjusterView.exportScale = newValue }
    }
    
    /// 图片是否需要裁剪
    var isCropedImage: Bool {
        adjusterView.isCropedImage
    }
    
    /// 裁剪图片
    func cropImage(
        _ completion: @escaping (Result<ImageEditedResult, EditorError>) -> Void
    ) {
        adjusterView.cropImage(completion: completion)
    }
    
    /// 视频是否需要裁剪
    var isCropedVideo: Bool {
        adjusterView.isCropedVideo
    }
    
    /// 裁剪视频
    func cropVideo(
        factor: EditorVideoFactor,
        filter: VideoCompositionFilter? = nil,
        progress: ((CGFloat) -> Void)? = nil,
        completion: @escaping (Result<VideoEditedResult, EditorError>) -> Void
    ) {
        adjusterView.cropVideo(
            factor: factor,
            filter: filter,
            progress: progress,
            completion: completion
        )
    }
    
    /// 取消视频裁剪
    func cancelVideoCroped() {
        adjusterView.cancelVideoCroped()
    }
    
    /// 清空上一次裁剪视频时的url缓存
    func removeVideoURLCache() {
        adjusterView.lastVideoFator = nil
    }
}

// MARK: 旋转
public extension EditorView {
    
    /// 当前旋转的角度
    var angle: CGFloat {
        adjusterView.currentAngle
    }
    
    /// 当连续旋转开始时赋值true, 结束时赋值false
    var isContinuousRotation: Bool {
        get { adjusterView.isContinuousRotation }
        set { adjusterView.isContinuousRotation = newValue }
    }
    
    /// Rotate custom angle
    /// 旋转自定义角度
    /// angle > 0 顺时针
    /// angle < 0 逆时针
    func rotate(_ angle: CGFloat, animated: Bool, completion: (() -> Void)? = nil) {
        if layoutContent {
            operates.append(.rotate(angle, completion))
            return
        }
        if reloadContent {
            reloadOperates.append(.rotate(angle, completion))
            return
        }
        adjusterView.rotate(angle, animated: animated, completion: completion)
    }
    
    /// Rotate left 90°
    /// 向左旋转90°
    func rotateLeft(_ animated: Bool, completion: (() -> Void)? = nil) {
        if layoutContent {
            operates.append(.rotateLeft(completion))
            return
        }
        if reloadContent {
            reloadOperates.append(.rotateLeft(completion))
            return
        }
        adjusterView.rotateLeft(animated, completion: completion)
    }
    
    /// Rotate right 90°
    /// 向右旋转90°
    func rotateRight(_ animated: Bool, completion: (() -> Void)? = nil) {
        if layoutContent {
            operates.append(.rotateRight(completion))
            return
        }
        if reloadContent {
            reloadOperates.append(.rotateRight(completion))
            return
        }
        adjusterView.rotateRight(animated, completion: completion)
    }
}

// MARK: 镜像
public extension EditorView {
    
    /// horizontal mirror
    /// 水平镜像
    func mirrorHorizontally(_ animated: Bool, completion: (() -> Void)? = nil) {
        if layoutContent {
            operates.append(.mirrorHorizontally(completion))
            return
        }
        if reloadContent {
            reloadOperates.append(.mirrorHorizontally(completion))
            return
        }
        adjusterView.mirrorHorizontally(animated: animated, completion: completion)
    }
    
    /// 垂直镜像
    func mirrorVertically(_ animated: Bool, completion: (() -> Void)? = nil) {
        if layoutContent {
            operates.append(.mirrorVertically(completion))
            return
        }
        if reloadContent {
            reloadOperates.append(.mirrorVertically(completion))
            return
        }
        adjusterView.mirrorVertically(animated: animated, completion: completion)
    }
}

// MARK: 重置编辑
public extension EditorView {
    
    /// Is it possible to reset edit
    /// 是否可以重置编辑
    var canReset: Bool {
        adjusterView.canReset
    }
    
    /// Reset edit
    /// 重置编辑
    func reset(_ animated: Bool, completion: (() -> Void)? = nil) {
        if layoutContent {
            operates.append(.reset(completion))
            return
        }
        if reloadContent {
            reloadOperates.append(.reset(completion))
            return
        }
        adjusterView.reset(animated, completion: completion)
    }
}

// MARK: 修改frame后更新视图
public extension EditorView {
    
    /// Update Views
    /// 更新内部视图的frame
    func update() {
        resetZoomScale(false)
        adjusterView.prepareUpdate()
        updateEditSize()
        updateContentSize()
        adjusterView.update()
        if editState == .normal {
            setCustomMaskFrame(false)
        }
    }
}
