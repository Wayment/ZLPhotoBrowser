//
//  ZLWatermarkView.swift
//  ZLPhotoBrowser
//
//  Created by wyman on 2023/8/9.
//

import UIKit

// 继承自UIView
class ZLWatermarkView: UIView {
    
    var watermark: String  = "" {
        didSet {
          // 水印文字有更新，应该重新绘制
            setNeedsDisplay()
        }
    }
    var wColor: UIColor = .black
    var wFontSize: CGFloat = 15
    var wAlpha: CGFloat = 1.0
    
    
    /// 时间格式化
    private var dateFormater = DateFormatter()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reload(_ watermark: String, color: UIColor, fontSize: CGFloat, fontAlpha: CGFloat = 1.0) {
        wColor = color
        wFontSize = fontSize
        wAlpha = fontAlpha
        self.watermark = watermark
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
          // 布局有变动，更新水印
        self.setNeedsDisplay()
    }

      // 绘制水印
    override func draw(_ rect: CGRect) {
      // 获取上下文对象
        let context = UIGraphicsGetCurrentContext()
      // 保存上下文状态
        context?.saveGState()
        defer {
          // 绘制完成后，恢复状态
            context?.restoreGState()
        }
          // 设置填充颜色为透明
        UIColor.clear.setFill()
          // 用透明色清除整个视图，重新绘制内容
        context?.clear(rect)
          // 设置混合模式为柔光，能更好的让水印文字与内容混合，减少水印的突兀感。
        context?.setBlendMode(.softLight)
        // 平移和旋转画布，目的是绘制倾斜的水印
        context?.translateBy(x: rect.width / 2, y: rect.height / 2)
        context?.rotate(by: -(CGFloat.pi / 4))
        context?.translateBy(x: -rect.width / 2, y: -rect.height / 2)

          // 构造水印内容
        let textAttribute:[NSAttributedString.Key : Any] =  [.foregroundColor: wColor.withAlphaComponent(wAlpha),
                                                             .font: UIFont.systemFont(ofSize: wFontSize)]
        let text = watermark as NSString
        let textSize = text.boundingRect(with: CGSize(width: .max, height: .max), options: .usesLineFragmentOrigin, attributes: textAttribute, context: nil)
          // 每个水印的横向距离
        let stepX: CGFloat = textSize.width + 20
        // 每个水印的纵向距离
        let stepY: CGFloat = textSize.height + 20
          
        let w = (sqrt(pow(rect.width, 2)+pow(rect.height, 2)))
        var y: CGFloat = -w
          // 让相邻两行的水印交错排列
        var doOffset = false
          // 循环绘制水印，充满屏幕，之所以是两倍宽度，是为了让屏幕边缘也有一些被裁切了一般的水印，让水印填充得更满
        while y < 2*w {
            defer {
                y += stepY
                doOffset.toggle()
            }
            var x: CGFloat = -2*w
            if doOffset {
                x -= stepX/2
            }
            while x < w {
                defer { x += stepX }
                let p = CGPoint(x: x, y: y)
                  // 绘制文字
                text.draw(at: p, withAttributes:textAttribute)
            }
        }
    }
}

