
/**
 * PhotoViewer
 * PhotoViewController
 *
 * Copyright (c) 2016 Nathan Blamires
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
 * OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

class PhotoViewController: UIViewController, UIScrollViewDelegate {
    
    // view outlets
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentWidthConstraint: NSLayoutConstraint!
    
    // data
    var allPhotoScrollViews: Array<UIScrollView> = []
    var allPhotos: Array<Photo> = []
    var currentPhotoIndex: Int = 0
    
    // delegate
    var galleryDelegate: GalleryDelegate?
    var statusBarHidden: Bool = false
    var scrollViewDragging: Bool = false
    
    // MARK: Public Setup Methods
    
    func setupWithPhotos(photos: [Photo], selectedPhotoIndex: Int){
        allPhotos = photos
        currentPhotoIndex = selectedPhotoIndex
    }

    // MARK: Setup methods
    
    // adds styling and image views
    override func viewDidLoad() {

        updateTitle()
        scrollView.delegate = self
        
        // add colours
        view.backgroundColor = UIColor.black
        titleLabel.textColor = UIColor.white
        colourButton(button: exitButton)
        colourButton(button: moreButton)
        
        // add shadows
        addShadowToView(view: exitButton)
        addShadowToView(view: moreButton)
        addShadowToView(view: titleLabel)
        
        // add image views
        setupImageViews()
    }
    
    private func setupImageViews(){

        // create all image views
        var previousView: UIView = contentView
        for x in 0...allPhotos.count-1 {
            
            let photo = allPhotos[x]
            
            // create sub scrollview
            let subScrollView = UIScrollView()
            subScrollView.delegate = self
            contentView.addSubview(subScrollView)
            allPhotoScrollViews.append(subScrollView)
            
            // create imageview
            let imageView = UIImageView(image: photo.image)
            imageView.contentMode = .scaleAspectFill
            subScrollView.addSubview(imageView)
            
            // add subScrollView constraints
            subScrollView.translatesAutoresizingMaskIntoConstraints = false
            let attribute: NSLayoutAttribute = (x == 0) ? .leading : .trailing
            scrollView.addConstraint(NSLayoutConstraint(item: subScrollView, attribute: .leading, relatedBy: .equal, toItem: previousView, attribute: attribute, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: subScrollView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: subScrollView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: subScrollView, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0))
            
            // add imageview constraints
            imageView.translatesAutoresizingMaskIntoConstraints = false
            subScrollView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: (photo.image.size.width / photo.image.size.height), constant: 0))
            subScrollView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: subScrollView, attribute: .centerX, multiplier: 1, constant: 0))
            subScrollView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: subScrollView, attribute: .centerY, multiplier: 1, constant: 0))

            // add imageview side constraints
            for attribute: NSLayoutAttribute in [.top, .bottom, .leading, .trailing] {
                let constraintLowPriority = NSLayoutConstraint(item: imageView, attribute: attribute, relatedBy: .equal, toItem: subScrollView, attribute: attribute, multiplier: 1, constant: 0)
                let constraintGreaterThan = NSLayoutConstraint(item: imageView, attribute: attribute, relatedBy: .greaterThanOrEqual, toItem: subScrollView, attribute: attribute, multiplier: 1, constant: 0)
                constraintLowPriority.priority = UILayoutPriority(rawValue: 750)
                subScrollView.addConstraints([constraintLowPriority,constraintGreaterThan])
            }
            
            // set as previous
            previousView = subScrollView
        }
        let xOffset = CGFloat(currentPhotoIndex) * scrollView.frame.size.width
        scrollView.contentOffset = CGPoint(x:xOffset, y:0)
    }
    
    // ensure scroll view has correct content size when the view size changes
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentWidthConstraint.constant = CGFloat(allPhotos.count) * scrollView.frame.size.width
        if !scrollViewDragging {
            scrollView.contentOffset = CGPoint(x: CGFloat(currentPhotoIndex) * scrollView.frame.size.width, y:0)
        }
    }

    // MARK: Styling Methods
    
    private func colourButton(button: UIButton){
        let tintableImage = button.backgroundImage(for: .normal)!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        button.setBackgroundImage(tintableImage, for: .normal)
        button.tintColor = UIColor.white
    }
    
    private func addShadowToView(view: UIView){
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.7
        view.layer.shadowOffset = CGSize(width:2.0, height: 2.0)
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            scrollViewDragging = true
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            scrollViewDragging = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView && scrollViewDragging {
            currentPhotoIndex = getCurrentPageIndex()
            updateTitle()
        }
    }
    
    // MARK: Utility Methods
    
    private func getCurrentPageIndex() -> Int {
        return Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
    }
    
    private func updateTitle(){
        titleLabel.text = allPhotos[currentPhotoIndex].title
    }

    // MARK: Button Actions
    
    @IBAction func moreButtonSelected() {
        // do something
    }
    
    @IBAction func backButtonSelected() {
        galleryDelegate?.updateSelectedIndex(newIndex: currentPhotoIndex)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Status Bar
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        statusBarHidden = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        statusBarHidden = false
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var prefersStatusBarHidden : Bool {
        return statusBarHidden
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
}

// MARK: ImageTransitionProtocol

extension PhotoViewController: ImageTransitionProtocol {
    
    // 1: hide scroll view containing images
    func tranisitionSetup(){
        let photo = allPhotos[currentPhotoIndex]
        titleLabel.text = photo.title
        scrollView.isHidden = true
    }
    
    // 2; unhide images and set correct image to be showing
    func tranisitionCleanup(){
        scrollView.isHidden = false
        let xOffset = CGFloat(currentPhotoIndex) * scrollView.frame.size.width
        scrollView.contentOffset = CGPoint(x: xOffset, y: 0)
    }
    
    // 3: return the imageView window frame
    func imageWindowFrame() -> CGRect{

        let photo = allPhotos[currentPhotoIndex]
        let scrollWindowFrame = scrollView.superview!.convert(scrollView.frame, to: nil)
        
        let scrollViewRatio = scrollView.frame.size.width / scrollView.frame.size.height
        let imageRatio = photo.image.size.width / photo.image.size.height
        let touchesSides = (imageRatio > scrollViewRatio)
        
        if touchesSides {
            let height = scrollWindowFrame.size.width / imageRatio
            let yPoint = scrollWindowFrame.origin.y + (scrollWindowFrame.size.height - height) / 2
            return CGRect(x: scrollWindowFrame.origin.x, y: yPoint, width: scrollWindowFrame.size.width, height: height)
        } else {
            let width = scrollWindowFrame.size.height * imageRatio
            let xPoint = scrollWindowFrame.origin.x + (scrollWindowFrame.size.width - width) / 2
            return CGRect(x: xPoint, y: scrollWindowFrame.origin.y, width: width, height: scrollWindowFrame.size.height)
        }
    }
}
