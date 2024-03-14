
import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var albumCoverImage: UIImageView!
    @IBOutlet private weak var albumTitleLabel: UILabel!
    @IBOutlet private weak var albumArtistLabel: UILabel!
    
    var album: Album?
    
    func configure(album: Album) {
        self.album = album
        albumTitleLabel.text = album.title
        albumArtistLabel.text = album.artist
        albumCoverImage.image = album.cover
    }
}
