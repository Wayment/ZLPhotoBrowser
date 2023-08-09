//
//  ZLEditWatermarkToolsView.swift
//  ZLPhotoBrowser
//
//  Created by wyman on 2023/8/9.
//

import UIKit
import SnapKit

class ZLEditWatermarkToolsView: UIView {
    
    var changeWatermarkBlock: (() -> ())?
    
    var textSize: CGFloat {
        return CGFloat(fontSlide.value)
    }
    
    var textAlpha: CGFloat {
        return CGFloat(alphaSlide.value)
    }
    
    var textColor: UIColor {
        return currentDrawColor
    }
    
    var watermark: String {
        return textView.text
    }
    
    private var currentDrawColor = ZLPhotoConfiguration.default().editImageConfiguration.defaultDrawColor

    private let drawColors: [UIColor] = ZLPhotoConfiguration.default().editImageConfiguration.drawColors
    
    private lazy var fontSlide: ZLEditImageSlider = {
        let slide = ZLEditImageSlider()
        slide.title = "大小"
        slide.minimumValue = 12
        slide.maximumValue = 36
        slide.value = 24
        slide.changeValueBlock = {[weak self] _ in
            self?.changeWatermarkBlock?()
        }
        return slide
    }()
    
    private lazy var alphaSlide: ZLEditImageSlider = {
        let slide = ZLEditImageSlider()
        slide.title = "透明度"
        slide.minimumValue = 0.0
        slide.maximumValue = 1.0
        slide.value = 0.5
        slide.changeValueBlock = {[weak self] _ in
            self?.changeWatermarkBlock?()
        }
        return slide
    }()
    
    private lazy var textTipLabel: UILabel = {
        let lable = UILabel()
        lable.textColor = .zl.hex(0xFFFFFF)
        lable.font = .systemFont(ofSize: 13)
        lable.text = "文本"
        return lable
    }()
    
    private lazy var textView: UITextView = {
        let view = UITextView()
        view.textAlignment = .left
        view.backgroundColor = .zl.hex(0x181A3E)
        view.layer.cornerRadius = 5
        view.textColor = .zl.hex(0xFFFFFF)
        view.font = .systemFont(ofSize: 13)
        view.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        view.text = "侵权必究"
        view.returnKeyType = .done
        view.delegate = self
        return view
    }()
    
    private lazy var colorTipLabel: UILabel = {
        let lable = UILabel()
        lable.textColor = .zl.hex(0xFFFFFF)
        lable.font = .systemFont(ofSize: 13)
        lable.text = "文字"
        return lable
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let drawColorLayout = UICollectionViewFlowLayout()
        let drawColorItemWidth: CGFloat = 36
        drawColorLayout.itemSize = CGSize(width: drawColorItemWidth, height: drawColorItemWidth)
        drawColorLayout.minimumLineSpacing = 4
        drawColorLayout.minimumInteritemSpacing = 0
        drawColorLayout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: drawColorLayout)
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        ZLDrawColorCell.self.zl.register(view)
        return view
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .zl.hex(0x0F1023).withAlphaComponent(0.8)
        addSubview(fontSlide)
        addSubview(alphaSlide)
        addSubview(textView)
        addSubview(textTipLabel)
        addSubview(colorCollectionView)
        addSubview(colorTipLabel)
        
        alphaSlide.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(20)
        }
        fontSlide.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(alphaSlide.snp.top).offset(-16)
            make.height.equalTo(20)
        }
        textView.snp.makeConstraints { make in
            make.bottom.equalTo(fontSlide.snp.top).offset(-8)
            make.left.equalToSuperview().offset(81)
            make.right.equalToSuperview().offset(-50)
            make.height.equalTo(39)
        }
        textTipLabel.snp.makeConstraints { make in
            make.centerY.equalTo(textView)
            make.right.equalTo(textView.snp.left).offset(-14)
        }
        colorCollectionView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(81)
            make.right.equalToSuperview().offset(-50)
            make.bottom.equalTo(textView.snp.top).offset(-8)
            make.height.equalTo(36)
        }
        colorTipLabel.snp.makeConstraints { make in
            make.centerY.equalTo(colorCollectionView)
            make.right.equalTo(colorCollectionView.snp.left).offset(-14)
        }
    }

}


extension ZLEditWatermarkToolsView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        changeWatermarkBlock?()
    }
    
}

extension ZLEditWatermarkToolsView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return drawColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLDrawColorCell.zl.identifier, for: indexPath) as! ZLDrawColorCell
        
        let c = drawColors[indexPath.row]
        cell.color = c
        if c == currentDrawColor {
            cell.bgWhiteView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1)
        } else {
            cell.bgWhiteView.layer.transform = CATransform3DIdentity
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentDrawColor = drawColors[indexPath.row]
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        collectionView.reloadData()
        changeWatermarkBlock?()
    }
    
}



class ZLEditImageSlider: UIView {
    
    var changeValueBlock: ((_ value: Float) -> ())?
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var minimumValue: Float = 0 {
        didSet {
            slider.minimumValue = minimumValue
        }
    }
    
    var maximumValue: Float = 0 {
        didSet {
            slider.maximumValue = maximumValue
            maxLabel.text = "\(Int(maximumValue))"
        }
    }
    
    var value: Float {
        get {
            return slider.value
        }
        set {
            slider.value = newValue
        }
    }
    
    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.setThumbImage(UIImage.zl.buildImage(color: .white, size: CGSize(width: 13, height: 13), cornerRadius: 6.5), for: .normal)
        slider.minimumTrackTintColor = .zl.hex(0x222555)
        slider.addTarget(self, action:#selector(sliderValurChanged(_:for:)), for: .valueChanged)
        return slider
    }()
    
    private lazy var titleLabel: UILabel = {
        let lable = UILabel()
        lable.textColor = .zl.hex(0xFFFFFF)
        lable.font = .systemFont(ofSize: 13)
        lable.text = ""
        return lable
    }()
    
    private lazy var maxLabel: UILabel = {
        let lable = UILabel()
        lable.textColor = .zl.hex(0xFFFFFF)
        lable.font = .systemFont(ofSize: 14)
        lable.text = ""
        return lable
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    private func setupUI() {
        addSubview(slider)
        addSubview(titleLabel)
        addSubview(maxLabel)
        
        slider.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(82)
            make.right.equalToSuperview().offset(-77)
            make.top.bottom.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.right.equalTo(slider.snp.left).offset(-14)
            make.centerY.equalToSuperview()
        }
        maxLabel.snp.makeConstraints { make in
            make.left.equalTo(slider.snp.right).offset(12)
            make.centerY.equalToSuperview()
        }
        
    }
    
    @objc func sliderValurChanged(_ slider: UISlider?, for event: UIEvent?) {
        guard let touchEvent = event?.allTouches?.first else { return }
        if touchEvent.phase == .ended {
            changeValueBlock?(slider?.value ?? 0)
        }
    }

    
}

