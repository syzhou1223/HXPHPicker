//
//  EditorStickersContentView.swift
//  HXPHPicker
//
//  Created by Slience on 2023/4/13.
//

import UIKit
import AVKit

class EditorStickersContentView: UIView {
    var scale: CGFloat = 1
    var item: EditorStickerItem
    init(item: EditorStickerItem) {
        self.item = item
        super.init(frame: item.frame)
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    func update(item: EditorStickerItem) {
        self.item = item
        if !frame.equalTo(item.frame) {
            frame = item.frame
        }
    }
    func updateText() {
        
    }
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        gestureRecognizer.delegate = self
        super.addGestureRecognizer(gestureRecognizer)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditorStickersContentView: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if otherGestureRecognizer.view is EditorView {
            return false
        }
        if otherGestureRecognizer is UITapGestureRecognizer || gestureRecognizer is UITapGestureRecognizer {
            return true
        }
        if let view = gestureRecognizer.view, view == self,
           let otherView = otherGestureRecognizer.view, otherView == self {
            return true
        }
        return false
    }
}

class EditorStickersContentImageView: EditorStickersContentView {
    lazy var imageView: ImageView = {
        let view = ImageView()
        if let imageData = item.imageData {
            view.setImageData(imageData)
        }else {
            view.image = item.image
        }
        return view
    }()
    
    override init(item: EditorStickerItem) {
        super.init(item: item)
        if item.isText {
            imageView.layer.shadowColor = UIColor.black.withAlphaComponent(0.8).cgColor
        }
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(item: EditorStickerItem) {
        super.update(item: item)
        
        if imageView.image != item.image {
            imageView.image = item.image
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
}

class EditorStickersContentAudioView: EditorStickersContentView {
    lazy var animationView: EditorAudioAnimationView = {
        let view = EditorAudioAnimationView(hexColor: "#ffffff")
        view.frame = CGRect(x: 2, y: 0, width: 20, height: 15)
        view.startAnimation()
        return view
    }()
    
    lazy var textLayer: CATextLayer = {
        let textLayer = CATextLayer()
        let fontSize: CGFloat = 25
        let font = UIFont.boldSystemFont(ofSize: fontSize)
        textLayer.font = font
        textLayer.fontSize = fontSize
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.truncationMode = .end
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.alignmentMode = .left
        textLayer.isWrapped = true
        return textLayer
    }()
    
    override init(item: EditorStickerItem) {
        super.init(item: item)
        addSubview(animationView)
        layer.addSublayer(textLayer)
        switch item.type {
        case .audio(let audio):
            setupText(audio.text)
            audio.textDidChange = { [weak self] in
                self?.setupText($0)
            }
        default:
            break
        }
    }
    
    func setupText(_ text: String) {
        if let str = textLayer.string as? String,
           str == text {
           return
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        textLayer.string = text
        updateText()
        CATransaction.commit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(item: EditorStickerItem) {
        super.update(item: item)
    }
    
    override func updateText() {
        guard let text = textLayer.string as? String,
              let font = textLayer.font as? UIFont else {
            return
        }
        let textSize = text.size(ofFont: font, maxWidth: ceil(width * scale), maxHeight: CGFloat(CGFLOAT_MAX))
        if !textLayer.frame.size.equalTo(textSize) {
            textLayer.frame = CGRect(
                origin: .init(x: 0, y: animationView.frame.maxY + 3),
                size: .init(width: ceil(textSize.width), height: ceil(textSize.height))
            )
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateText()
    }
}
