//
//  ImageViewController.swift
//  Smashtag
//
//  Created by Brian Jewkes on 7/4/15.
//  Copyright (c) 2015 Brian Jewkes. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    var image: UIImage? = nil {
        didSet {
            if let image = self.image{
                imageView.image = image
                imageView.sizeToFit()
                scrollView?.contentSize = imageView.frame.size
            } else {
                if view.window != nil{
                    fetchImage()
                }
            }
        }
    }
    
    var imageData: MediaItem?
    
    private func fetchImage(){
        println("ImageViewController: fethchImage not yet implemented")
    }
    
    private var imageView = UIImageView()
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = setMaxZoomOut()
            scrollView.maximumZoomScale = 1
            scrollView.zoomScale = setMaxZoomOut()
            
        }
    }
    
    //calculate zoom to fit screen
    private func setMaxZoomOut() -> CGFloat{
        return 0.5
    }
    
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
    }
}
