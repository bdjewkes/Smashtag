//
//  ImageViewController.swift
//  Smashtag
//
//  Created by Brian Jewkes on 7/4/15.
//  Copyright (c) 2015 Brian Jewkes. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    //MARK: Model
    
    var image: UIImage? = nil {
        didSet {
            if let image = self.image{
                imageView.image = image
                imageView.sizeToFit()
                scrollView?.contentSize = imageView.frame.size
            }
        }
    }
    
    var imageData: MediaItem? {
        didSet {
            if image == nil {
                fetchImage(imageData!.url)
            }
        }
    }
    
    private func fetchImage(url: NSURL){
        var fetchedImage: UIImage? = nil
        let qos = Int(QOS_CLASS_USER_INITIATED.value)
        dispatch_async(dispatch_get_global_queue(qos, 0)) { () -> Void in
            let imageData = NSData(contentsOfURL: url) //
            dispatch_async(dispatch_get_main_queue()) {
                if self.image != nil {
                    self.image = UIImage(data: imageData!)
                }
            }
        }
    }
    
    //MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
    }
    
    private var imageView = UIImageView()
    
    
    //MARK: ScrollView Configuration
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = setMaxZoomOut()
            scrollView.maximumZoomScale = setMaxZoomOut() * 3
            scrollView.zoomScale = setMaxZoomOut()
        }
    }

    private func setMaxZoomOut() -> CGFloat{
        return min(imageView.bounds.width / scrollView.bounds.width, imageView.bounds.height / scrollView.bounds.height)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.zoomScale = setMaxZoomOut()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }

   
}
