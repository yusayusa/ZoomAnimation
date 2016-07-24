//
// TransitionController.swift
// ZoomAnimation
//
// Copyright (c) 2016 Kazuki Yusa
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

class TransitionController: NSObject, UIViewControllerAnimatedTransitioning {

    // pushなら forward == true
    var forward = false
    
    // アニメーションの時間
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        
        return 0.4
    }
    
    // アニメーションの定義
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        if self.forward {
            // Push時のアニメーション
            forwardTransition(transitionContext)
        } else {
            // Pop時のアニメーション
            backwardTransition(transitionContext)
        }
    }
    
    // Push時のアニメーション
    private func forwardTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) else {
            return
        }
        guard let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
            return
        }
        guard let containerView = transitionContext.containerView() else {
            return
        }
        
        // 遷移先のviewをaddSubviewする（fromVC.viewは最初からcontainerViewがsubviewとして持っている）
        containerView.addSubview(toVC.view)
        
        // addSubviewでレイアウトが崩れるため再レイアウトする
        toVC.view.layoutIfNeeded()
        
        // アニメーション用のimageViewを新しく作成する
        guard let sourceImageView = (fromVC as? ViewController)?.createImageView() else {
            return
        }
        guard let destinationImageView = (toVC as? DetailViewController)?.createImageView() else {
            return
        }
        
        // 遷移先のimageViewをaddSubviewする
        containerView.addSubview(sourceImageView)
        
        toVC.view.alpha = 0.0
        (toVC as! DetailViewController).imageView!.hidden = true
        (toVC as! DetailViewController).image = sourceImageView.image
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.05, options: .CurveEaseInOut, animations: { () -> Void in
            
            // アニメーション開始
            // 遷移先のimageViewのframeとcontetModeを遷移元のimageViewに代入
            sourceImageView.frame = destinationImageView.frame
            sourceImageView.contentMode = destinationImageView.contentMode

            // cellのimageViewを非表示にする
            (fromVC as? ViewController)?.selectedImageView?.hidden = true
            
            toVC.view.alpha = 1.0
            
            }) { (finished) -> Void in
                (toVC as! DetailViewController).imageView?.hidden = false
                sourceImageView.removeFromSuperview()
                // アニメーション終了
                transitionContext.completeTransition(true)
        }
    }
    
    // Pop時のアニメーション
    private func backwardTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // Pushと逆のアニメーションを書く

        guard let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) else {
            return
        }
        guard let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
            return
        }
        guard let containerView = transitionContext.containerView() else {
            return
        }
        
        // toView -> fromViewの順にaddSubview
        containerView.addSubview(toVC.view)
        containerView.addSubview(fromVC.view)
        
        guard let sourceImageView = (fromVC as? DetailViewController)?.createImageView() else {
            return
        }
        guard let destinationImageView = (toVC as? ViewController)?.createImageView() else {
            return
        }

        containerView.addSubview(sourceImageView)
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.05, options: .CurveEaseInOut, animations: { () -> Void in

            sourceImageView.frame = destinationImageView.frame
            fromVC.view.alpha = 0.0
            
            }) { (finished) -> Void in
                
                sourceImageView.removeFromSuperview()
                
                (toVC as? ViewController)?.selectedImageView?.hidden = false

                transitionContext.completeTransition(true)
        }
    }
}
