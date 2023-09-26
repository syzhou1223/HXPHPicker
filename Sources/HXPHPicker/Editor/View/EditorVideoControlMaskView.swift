//
//  EditorVideoControlMaskView.swift
//  HXPHPicker
//
//  Created by Silence on 2023/5/13.
//

import UIKit

protocol EditorVideoControlMaskViewDelegate: AnyObject {
    func frameMaskView(leftValidRectDidChanged frameMaskView: EditorVideoControlMaskView)
    func frameMaskView(leftValidRectEndChanged frameMaskView: EditorVideoControlMaskView)
    func frameMaskView(rightValidRectDidChanged frameMaskView: EditorVideoControlMaskView)
    func frameMaskView(rightValidRectEndChanged frameMaskView: EditorVideoControlMaskView)
}

class EditorVideoControlMaskView: UIView {
    let controlWidth: CGFloat = 18
    
    weak var delegate: EditorVideoControlMaskViewDelegate?
    var validRect: CGRect = .zero {
        didSet {
            leftControl.frame = CGRect(x: validRect.minX - controlWidth, y: 0, width: controlWidth, height: height)
            leftImageView.center = .init(x: leftControl.width / 2, y: leftControl.height / 2)
            rightControl.frame = CGRect(x: validRect.maxX, y: 0, width: controlWidth, height: height)
            rightImageView.center = .init(x: rightControl.width / 2, y: rightControl.height / 2)
            topView.frame = .init(x: leftControl.frame.maxX, y: 0, width: validRect.width, height: 4)
            bottomView.frame = .init(x: leftControl.frame.maxX, y: leftControl.frame.maxY - 4, width: validRect.width, height: 4)
            drawMaskLayer()
            
            if #available(iOS 11.0, *) { }else {
                leftControl.cornersRound(radius: 4, corner: [.topLeft, .bottomLeft])
                rightControl.cornersRound(radius: 4, corner: [.topRight, .bottomRight])
            }
        }
    }
    var isShowFrame: Bool = false
    var minWidth: CGFloat = 0
    lazy var maskLayer: CAShapeLayer = {
        let maskLayer = CAShapeLayer()
        maskLayer.contentsScale = UIScreen.main.scale
        return maskLayer
    }()
    
    func drawMaskLayer() {
        let maskPath = UIBezierPath(rect: bounds)
        maskPath.append(
            UIBezierPath(
                rect: CGRect(
                    x: validRect.minX,
                    y: validRect.minY + 4,
                    width: validRect.width,
                    height: validRect.height - 8
                )
            ).reversing()
        )
        maskLayer.path = maskPath.cgPath
        
    }
    
    lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    var arrowNormalColor: UIColor = .white
    var arrowHighlightedColor: UIColor = .black
    var frameHighlightedColor: UIColor = "#FDCC00".color
    
    lazy var leftImageView: UIImageView = {
        let view = UIImageView(image: "hx_editor_video_control_arrow_left".image?.withRenderingMode(.alwaysTemplate))
        view.size = view.image?.size ?? .zero
        view.tintColor = arrowNormalColor
        return view
    }()
    
    lazy var leftControl: UIView = {
        let leftControl = UIView()
        leftControl.tag = 0
        if #available(iOS 11.0, *) {
            leftControl.cornersRound(radius: 4, corner: [.topLeft, .bottomLeft])
        }
        leftControl.addSubview(leftImageView)
        let panGR = PhotoPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction(panGR:)))
        leftControl.addGestureRecognizer(panGR)
        return leftControl
    }()
    
    lazy var rightImageView: UIImageView = {
        let view = UIImageView(image: "hx_editor_video_control_arrow_right".image?.withRenderingMode(.alwaysTemplate))
        view.size = view.image?.size ?? .zero
        view.tintColor = arrowNormalColor
        return view
    }()
    
    lazy var rightControl: UIView = {
        let rightControl = UIView()
        rightControl.tag = 1
        rightControl.addSubview(rightImageView)
        if #available(iOS 11.0, *) {
            rightControl.cornersRound(radius: 4, corner: [.topRight, .bottomRight])
        }
        let panGR = PhotoPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction(panGR:)))
        rightControl.addGestureRecognizer(panGR)
        return rightControl
    }()
    
//    lazy var mask_View: UIVisualEffectView = {
//        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
//        view.layer.mask = maskLayer
//        return view
//    }()
    
    lazy var mask_View: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.layer.mask = maskLayer
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        addSubview(mask_View)
        addSubview(topView)
        addSubview(bottomView)
        addSubview(leftControl)
        addSubview(rightControl)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mask_View.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var leftBeginRect: CGRect = .zero
    var rightBeginRect: CGRect = .zero
    @objc func panGestureRecognizerAction(panGR: UIPanGestureRecognizer) {
        let point = panGR.translation(in: self)
        switch panGR.state {
        case .began:
            leftBeginRect = leftControl.frame
            rightBeginRect = rightControl.frame
            switch panGR.view?.tag {
            case 0:
                delegate?.frameMaskView(leftValidRectDidChanged: self)
            case 1:
                delegate?.frameMaskView(rightValidRectDidChanged: self)
            default:
                break
            }
            updateFrameView()
        case .changed:
            var leftRect = leftBeginRect
            var rightRect = rightBeginRect
            switch panGR.view?.tag {
            case 0:
                leftRect.origin.x += point.x
                if leftRect.origin.x < 0 {
                    leftRect.origin.x = 0
                }
                if rightRect.origin.x - leftRect.maxX <= minWidth {
                    leftRect.origin.x = rightRect.origin.x - minWidth - leftRect.width
                }
                validRect = .init(x: leftRect.maxX, y: validRect.minY, width: rightRect.origin.x - leftRect.maxX, height: leftRect.height)
                delegate?.frameMaskView(leftValidRectDidChanged: self)
            case 1:
                rightRect.origin.x += point.x
                if rightRect.maxX > width {
                    rightRect.origin.x = width - rightRect.width
                }
                if rightRect.origin.x - leftRect.maxX <= minWidth {
                    rightRect.origin.x = leftRect.maxX + minWidth
                }
                validRect = .init(x: leftRect.maxX, y: validRect.minY, width: rightRect.origin.x - leftRect.maxX, height: leftRect.height)
                delegate?.frameMaskView(rightValidRectDidChanged: self)
            default:
                break
            }
            updateFrameView()
        case .ended, .failed, .cancelled:
            let leftRect = leftControl.frame
            let rightRect = rightControl.frame
            validRect = .init(x: leftRect.maxX, y: validRect.minY, width: rightRect.origin.x - leftRect.maxX, height: leftRect.height)
            switch panGR.view?.tag {
            case 0:
                delegate?.frameMaskView(leftValidRectEndChanged: self)
            case 1:
                delegate?.frameMaskView(rightValidRectEndChanged: self)
            default:
                break
            }
            updateFrameView()
        default:
            break
        }
    }
    
    func updateFrameView() {
        if rightControl.x - leftControl.frame.maxX < width - controlWidth * 2 || isShowFrame {
            UIView.animate(withDuration: 0.2) {
                self.topView.backgroundColor = self.frameHighlightedColor
                self.bottomView.backgroundColor = self.frameHighlightedColor
                self.leftControl.backgroundColor = self.frameHighlightedColor
                self.rightControl.backgroundColor = self.frameHighlightedColor
                self.leftImageView.tintColor = self.arrowHighlightedColor
                self.rightImageView.tintColor = self.arrowHighlightedColor
                self.mask_View.backgroundColor = .black.withAlphaComponent(0.5)
            }
        }else {
            UIView.animate(withDuration: 0.2) {
                self.topView.backgroundColor = .clear
                self.bottomView.backgroundColor = .clear
                self.leftControl.backgroundColor = .clear
                self.rightControl.backgroundColor = .clear
                self.leftImageView.tintColor = self.arrowNormalColor
                self.rightImageView.tintColor = self.arrowNormalColor
                self.mask_View.backgroundColor = .clear
            }
        }
    }
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var leftRect = leftControl.frame
        leftRect.origin.x -= controlWidth
        leftRect.size.width += controlWidth
        var rightRect = rightControl.frame
        rightRect.size.width += controlWidth
        if leftRect.contains(point) {
            return leftControl
        }
        if rightRect.contains(point) {
            return rightControl
        }
        return nil
    }
}
