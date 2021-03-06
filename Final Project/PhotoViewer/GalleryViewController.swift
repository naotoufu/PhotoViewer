
/**
 * PhotoViewer
 * GalleryViewController
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

class GalleryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var animationController: AnimationController = AnimationController()
    var hideSelectedCell: Bool = false
    
    // view outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // data
    var allPhotos: Array<Photo> = []
    var selectedIndex: Int?
    
    // MARK: Setup Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // generate photos
        title = "Photo Viewer"
        for x in 1...14 {
            let image = UIImage(named:"\(x).jpg")
            let title = "Photo \(x)"
            let photo = Photo(title: title, image: image!)
            allPhotos.append(photo)
        }

        // load collection
        collectionView.reloadData()
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: UICollectionViewDelegate, UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let padding: CGFloat = 1
        let minimum: CGFloat = 78

        let itemsPerRow = floor(collectionView.frame.size.width / minimum)
        let width = (collectionView.frame.size.width - ((itemsPerRow - 1)*padding)) / itemsPerRow
        return CGSize(width:width, height:width)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath as IndexPath) as! ImageCell
        let photo = allPhotos[indexPath.row]
        cell.imageView.image = (indexPath.row == selectedIndex && hideSelectedCell) ? nil : photo.image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "FullScreenSegue", sender: nil)
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: Segue Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! PhotoViewController
        destination.transitioningDelegate = self
        destination.galleryDelegate = self
        destination.setupWithPhotos(photos: allPhotos, selectedPhotoIndex: selectedIndex!)
    }
}

// MARK: UIViewControllerTransitioningDelegate

extension GalleryViewController: GalleryDelegate {
    func updateSelectedIndex(newIndex: Int){
        selectedIndex = newIndex
    }
}

protocol GalleryDelegate {
    func updateSelectedIndex(newIndex: Int)
}

// MARK: UIViewControllerTransitioningDelegate

// 1: Conforming to protocol
extension GalleryViewController: UIViewControllerTransitioningDelegate {
    
    // 2: presentation controller
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let photoViewController = presented as! PhotoViewController
        animationController.setupImageTransition( image: allPhotos[selectedIndex!].image,
                                                  fromDelegate: self,
                                                  toDelegate: photoViewController)
        return animationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let photoViewController = dismissed as! PhotoViewController
        animationController.setupImageTransition( image: allPhotos[selectedIndex!].image,
                                                  fromDelegate: photoViewController,
                                                  toDelegate: self)
        return animationController
    }
}

// MARK: ImageTransitionProtocol

extension GalleryViewController: ImageTransitionProtocol {
    
    // 1: hide selected cell for tranisition snapshot
    func tranisitionSetup(){
        hideSelectedCell = true
        collectionView.reloadData()
    }
    
    // 2: unhide selected cell after tranisition snapshot is taken
    func tranisitionCleanup(){
        hideSelectedCell = false
        collectionView.reloadData()
    }
    
    // 3: return window frame of selected image
    func imageWindowFrame() -> CGRect{
        let indexPath = IndexPath(row: selectedIndex!, section: 0)
        let attributes = collectionView.layoutAttributesForItem(at: indexPath as IndexPath)
        let cellRect = attributes!.frame
        return collectionView.convert(cellRect, to: nil)
    }
}
