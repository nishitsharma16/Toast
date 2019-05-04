//
//  Toast.swift
//  ContactApp
//
//  Created by B0095764 on 1/29/19.
//  Copyright © 2019 Mine. All rights reserved.
//

import Foundation
import UIKit

final class Toast : NSObject {
    
    let autoHideDuration : Double
    var queue = [String]()
    private var toastView : ToastView?
    
    
    private static let sharedVar: Toast = {
        let shared = Toast()
        return shared
    }()
    
    class func shared() -> Toast {
        return sharedVar
    }
    
    private override init() {
        autoHideDuration = 2.5
    }
    
    func showToastMessage(_ message: String?) {
        
        guard let msg = message, msg.count > 0 else {
            return
        }
        
        queue.append(msg)
        
        if let _ = toastView {
            return
        }
        
        processQueue()
    }
}

//Private Method Extension

extension Toast {
    
    @objc private func processQueue() {
        if queue.count == 0 {
            hide()
            return
        }
        
        let current = queue[0]
        queue.remove(at: 0)
        showCurrentMessage(current)
    }
    
    @objc private func handleToastTap(_ gesture: UIGestureRecognizer?) {
        if gesture?.state == .recognized {
            queue.removeAll()
            hide()
            NSObject.cancelPreviousPerformRequests(withTarget: self)
        }
    }
    
    private func dismissToast() {
        queue.removeAll()
        hide()
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    private func showCurrentMessage(_ message: String?) {
        
        if let _ = toastView {
            
        }
        else {
            toastView = ToastView(frame: CGRect.zero)
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleToastTap(_:)))
            toastView?.addGestureRecognizer(tap)
        }
        
        toastView?.setMessage(message ?? "")
        toastView?.alpha = 0.0
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .beginFromCurrentState, animations: { [weak self] in
            self?.toastView?.alpha = 1.0
        })
        
        perform(#selector(processQueue), with: nil, afterDelay: autoHideDuration)
    }
    
    private func hide() {
        let toast: UIView? = toastView
        toastView = nil
        
        UIView.animate(withDuration: 0.2, animations: {
            toast?.alpha = 0.0
        }) { finished in
            toast?.removeFromSuperview()
        }
    }
}

private struct ToastConstants {
    static let contentWidth : CGFloat = 280.0
}

private class ToastView: UIView {
    var margin: CGFloat = 0.0
    var offset: CGFloat = 0.0
    
    var message = ""
    let label: UILabel
    
    override init(frame: CGRect) {
        
        label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 0
        label.font = UIFont.regular(14.0)
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        super.init(frame: frame)
        
        margin = 12.0
        offset = 2.0
        clipsToBounds = true
        layer.cornerRadius = 8.0
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMessage(_ message: String?) {
        label.text = message
        
        let font: UIFont? = label.font
        let y: Float = 0.8
        
        let size: CGSize = message?.size(for: font,
                                         width: ToastConstants.contentWidth - 2.0 * margin) ?? CGSize.zero
                    
        let w = CGFloat(size.width + 2.0 * margin)
        let h = CGFloat(size.height + 2.0 * margin)
        
        frame = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: w, height: h)
        
        if  label.superview == nil {
            setupBlurView()
        }
        
        if let wind = UIApplication.shared.delegate?.window, let windowWidth = wind?.bounds.size.width, let windowHeight = wind?.bounds.size.height {
            wind?.addSubview(self)
            let position = CGFloat(round(Double(CGFloat(y) * (windowHeight))))
            center = CGPoint(x: windowWidth/2, y: position)
        }
    }
}

//Private Method Extension

extension ToastView {
    
    private func setupBlurView() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(blurEffectView)
        
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        vibrancyEffectView.frame = bounds
        
        var rect: CGRect = bounds
        rect = rect.insetBy(dx: margin, dy: margin)
        rect.origin.y -= offset
        label.frame = rect
        
        vibrancyEffectView.contentView.addSubview(label)
        blurEffectView.contentView.addSubview(label)
    }
}

extension UIFont {
    static func regular(_ size : CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .regular)
    }
}

extension String {
    func size(for font: UIFont?, width: CGFloat) -> CGSize {
        if font == nil {
            return CGSize.zero
        }
        
        var attrString: NSAttributedString? = nil
        if let font = font {
            attrString = NSAttributedString(string: self, attributes: [
                NSAttributedString.Key.font: font
                ])
        }
        return self.size(for: attrString, width: width)
    }
    
    private func size(for attrString: NSAttributedString?, width: CGFloat) -> CGSize {
        if attrString == nil {
            return CGSize.zero
        }
        
        let size = attrString?.boundingRect(with: CGSize(width: width, height: CGFloat(UInt.max)), options: .usesLineFragmentOrigin, context: nil)
        
        return CGSize(width: ceil(size?.width ?? 0), height: ceil(size?.height ?? 0))
    }
}

