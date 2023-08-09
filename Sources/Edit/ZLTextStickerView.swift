//
//  ZLTextStickerView.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/10/30.
//
//  Copyright (c) 2020 Long Zhang <495181165@qq.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

class ZLTextStickerView: ZLBaseStickerView<ZLTextStickerState> {
    static let fontSize: CGFloat = 32
    
    private static let edgeInset: CGFloat = 10
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
    
    var text: String
    
    var textColor: UIColor
    
    var style: ZLInputTextStyle
    
    var image: UIImage {
        didSet {
            imageView.image = image
        }
    }
    
    private lazy var optionView: ZLTextStickerOptionView = {
        let view = ZLTextStickerOptionView()
        view.deleteButton.addTarget(self, action: #selector(deleteClick), for: .touchUpInside)
        view.copyButton.addTarget(self, action: #selector(copyClick), for: .touchUpInside)
        view.modifyButton.addTarget(self, action: #selector(modifyClick), for: .touchUpInside)
        return view
    }()

    // Convert all states to model.
    override var state: ZLTextStickerState {
        return ZLTextStickerState(
            text: text,
            textColor: textColor,
            style: style,
            image: image,
            originScale: originScale,
            originAngle: originAngle,
            originFrame: originFrame,
            gesScale: gesScale,
            gesRotation: gesRotation,
            totalTranslationPoint: totalTranslationPoint
        )
    }
    
    deinit {
        zl_debugPrint("ZLTextStickerView deinit")
    }
    
    convenience init(state: ZLTextStickerState) {
        self.init(
            text: state.text,
            textColor: state.textColor,
            style: state.style,
            image: state.image,
            originScale: state.originScale,
            originAngle: state.originAngle,
            originFrame: state.originFrame,
            gesScale: state.gesScale,
            gesRotation: state.gesRotation,
            totalTranslationPoint: state.totalTranslationPoint,
            showBorder: false
        )
    }
    
    init(
        text: String,
        textColor: UIColor,
        style: ZLInputTextStyle,
        image: UIImage,
        originScale: CGFloat,
        originAngle: CGFloat,
        originFrame: CGRect,
        gesScale: CGFloat = 1,
        gesRotation: CGFloat = 0,
        totalTranslationPoint: CGPoint = .zero,
        showBorder: Bool = true
    ) {
        self.text = text
        self.textColor = textColor
        self.style = style
        self.image = image
        super.init(originScale: originScale, originAngle: originAngle, originFrame: originFrame, gesScale: gesScale, gesRotation: gesRotation, totalTranslationPoint: totalTranslationPoint, showBorder: showBorder)
        
        borderView.layer.borderWidth = 0
        borderView.addSubview(imageView)
        borderView.insertSubview(optionView, at: 0)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUIFrameWhenFirstLayout() {
        imageView.frame = borderView.bounds.insetBy(dx: Self.edgeInset, dy: Self.edgeInset)
        optionView.frame = bounds
    }
    
    override func tapAction(_ ges: UITapGestureRecognizer) {
        guard gesIsEnabled else { return }
        
        if let timer = timer, timer.isValid {
            delegate?.sticker(self, editText: text)
        } else {
            super.tapAction(ges)
        }
    }
    
    func changeSize(to newSize: CGSize) {
        // Revert zoom scale.
        transform = transform.scaledBy(x: 1 / originScale, y: 1 / originScale)
        // Revert ges scale.
        transform = transform.scaledBy(x: 1 / gesScale, y: 1 / gesScale)
        // Revert ges rotation.
        transform = transform.rotated(by: -gesRotation)
        transform = transform.rotated(by: -originAngle.zl.toPi)
        
        // Recalculate current frame.
        let center = CGPoint(x: self.frame.midX, y: self.frame.midY)
        var frame = self.frame
        frame.origin.x = center.x - newSize.width / 2
        frame.origin.y = center.y - newSize.height / 2
        frame.size = newSize
        self.frame = frame
        
        let oc = CGPoint(x: originFrame.midX, y: originFrame.midY)
        var of = originFrame
        of.origin.x = oc.x - newSize.width / 2
        of.origin.y = oc.y - newSize.height / 2
        of.size = newSize
        originFrame = of
        
        imageView.frame = borderView.bounds.insetBy(dx: Self.edgeInset, dy: Self.edgeInset)
        optionView.frame = bounds
        
        // Readd zoom scale.
        transform = transform.scaledBy(x: originScale, y: originScale)
        // Readd ges scale.
        transform = transform.scaledBy(x: gesScale, y: gesScale)
        // Readd ges rotation.
        transform = transform.rotated(by: gesRotation)
        transform = transform.rotated(by: originAngle.zl.toPi)
    }
    
    class func calculateSize(image: UIImage) -> CGSize {
        var size = image.size
        size.width += Self.edgeInset * 2
        size.height += Self.edgeInset * 2
        return size
    }
    
    override func hiddenBorder(_ isHidden: Bool) {
        super.hiddenBorder(isHidden)
        optionView.isHidden = isHidden
    }
    
    @objc func deleteClick() {
        delegate?.stickerDelete(self)
    }
    @objc func copyClick() {
        delegate?.stickerCopy(self)
    }
    @objc func modifyClick() {
        delegate?.sticker(self, editText: text)
    }
    
}

public class ZLTextStickerState: NSObject {
    let text: String
    let textColor: UIColor
    let style: ZLInputTextStyle
    let image: UIImage
    let originScale: CGFloat
    let originAngle: CGFloat
    let originFrame: CGRect
    let gesScale: CGFloat
    let gesRotation: CGFloat
    let totalTranslationPoint: CGPoint
    
    init(
        text: String,
        textColor: UIColor,
        style: ZLInputTextStyle,
        image: UIImage,
        originScale: CGFloat,
        originAngle: CGFloat,
        originFrame: CGRect,
        gesScale: CGFloat,
        gesRotation: CGFloat,
        totalTranslationPoint: CGPoint
    ) {
        self.text = text
        self.textColor = textColor
        self.style = style
        self.image = image
        self.originScale = originScale
        self.originAngle = originAngle
        self.originFrame = originFrame
        self.gesScale = gesScale
        self.gesRotation = gesRotation
        self.totalTranslationPoint = totalTranslationPoint
        super.init()
    }
}


class ZLTextStickerOptionView: UIView {
    
    private let iconWH: CGFloat = 23
    
    private lazy var backView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.zl.hex(0x1C83FF).cgColor
        view.layer.borderWidth = 2
        return view
    }()
    
    lazy var copyButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(.zl.getImage("zl_editimage_text_copy"), for: .normal)
        return btn
    }()
    
    lazy var deleteButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(.zl.getImage("zl_editimage_text_delete"), for: .normal)
        return btn
    }()
    
    lazy var rotateButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(.zl.getImage("zl_editimage_text_rotate"), for: .normal)
        return btn
    }()
    
    lazy var modifyButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(.zl.getImage("zl_ditimage_text_input"), for: .normal)
        btn.setImage(.zl.getImage("zl_ditimage_text_input"), for: .disabled)
        btn.isEnabled = false
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    private func setupUI() {
        addSubview(backView)
        addSubview(copyButton)
        addSubview(deleteButton)
        addSubview(rotateButton)
        addSubview(modifyButton)
        
        let margin = iconWH * 0.5
        backView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin))
        }
        deleteButton.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.size.equalTo(CGSize(width: iconWH, height: iconWH))
        }
        copyButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.size.equalTo(CGSize(width: iconWH, height: iconWH))
        }
        modifyButton.snp.makeConstraints { make in
            make.bottom.left.equalToSuperview()
            make.size.equalTo(CGSize(width: iconWH, height: iconWH))
        }
        rotateButton.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview()
            make.size.equalTo(CGSize(width: iconWH, height: iconWH))
        }
    }
}
