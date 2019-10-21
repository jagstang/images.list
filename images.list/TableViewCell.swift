import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var imagePreview: ImageView!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    public func configureWithImage(_ image: Image, placeholder: UIImage) {
        
        if imagePreview.imageUrlString != image.url {
            imagePreview.image = placeholder
            updateImageWidthConstraint(with: placeholder.size)
        }
        
        imagePreview.loadImage(fromURL: image.url, completion: { (size: CGSize) in
            self.updateImageWidthConstraint(with: size)
        })
        
        let ptHeight = Int(heightConstraint.constant)
        let ptWidth = Int(ptHeight * image.width / image.height)
        sizeLabel.text = "\(image.width)x\(image.height) (\(ptWidth)x\(ptHeight))"
    }
    
    private func updateImageWidthConstraint(with size: CGSize) {
        widthConstraint.constant = CGFloat(heightConstraint.constant * size.width / size.height)
    }
}
