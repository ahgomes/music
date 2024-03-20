import UIKit

class PlayerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

class MiniPlayerViewController: UIViewController {
    
    var current: Song?
    
    @IBOutlet private weak var coverImageView: UIImageView!
    @IBOutlet private weak var songTitleLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var ffButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure(song: nil)
    }
    
    func configure(song: Song?) {
        if let song = song {
            songTitleLabel.text = song.title
        } else {
            songTitleLabel.text = "Not Playing"
        }
        
        current = song
    }
}
