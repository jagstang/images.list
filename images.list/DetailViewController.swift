import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imagePreview: ImageView!
    @IBOutlet weak var jsonLabel: UILabel!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    var image: Image?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let placeholder = UIImage(named: "placeholder")
        imagePreview.image = placeholder
        if let size = placeholder?.size {
            updateImageHeightConstraint(with: size)
        }
        
        if let image = image {
            setupImage(image: image)
        }
    }
    
    private func setupImage(image: Image) {
        jsonLabel.text = image.prettyJson
        imagePreview.loadImage(fromURL: image.url, completion: { (size: CGSize) in
            self.updateImageHeightConstraint(with: size)
        })
    }
    
    private func updateImageHeightConstraint(with size: CGSize) {
        imageHeightConstraint.constant = CGFloat(imagePreview.frame.size.width * size.height / size.width)
    }
}
