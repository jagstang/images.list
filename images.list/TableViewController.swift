import UIKit

class TableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadMoreButton: UIButton!
    
    private let cellIdentifier = "ImageCell"
    private let segueIdentifier = "ImageDetail"
    
    private let imageProvider = ImageProvider()
    private let placeholderImage = UIImage(named: "placeholder")
    private let refreshControl = UIRefreshControl()
    
    private var imageForDetail: Image?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageProvider.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self

        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        
        loadMoreButton.isHidden = true
        activityIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imageProvider.requestData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            if let destination = segue.destination as? DetailViewController {
                if let image = imageForDetail {
                    destination.image = image
                }
            }
        }
    }
    
    @objc private func pullToRefresh(_ sender: Any) {
        imageProvider.refreshData()
        
        loadMoreButton.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    @IBAction func loadMoreTap(_ sender: Any) {
        imageProvider.requestNextPage()
        
        loadMoreButton.isHidden = true
        activityIndicator.startAnimating()
    }
}

extension TableViewController: ImageProviderDelegate {
    func didRecieveDataUpdate() {
        refreshControl.endRefreshing()
        activityIndicator.stopAnimating()
        loadMoreButton.isHidden = false
        
        tableView.reloadData()
    }
    
    func didFailDataUpdateWithError(error: ImageError) {
        let alert = UIAlertController(title: "Error", message: "Some trouble while getting images", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension TableViewController: UITableViewDelegate {}

extension TableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageProvider.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TableViewCell,
            let placeholder = placeholderImage else  {
            return UITableViewCell()
        }
        
        cell.configureWithImage(imageProvider.getBy(id: indexPath.row), placeholder: placeholder)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        imageForDetail = imageProvider.getBy(id: indexPath.row)
        self.performSegue(withIdentifier: segueIdentifier, sender: nil)
    }
}
