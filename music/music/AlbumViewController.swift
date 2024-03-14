
import UIKit

class AlbumViewController: UIViewController {
    @IBOutlet private weak var coverImageView: UIImageView!
    @IBOutlet private weak var albumTitleLabel: UILabel!
    @IBOutlet private weak var albumArtistLabel: UILabel!
    @IBOutlet private weak var songTableView: UITableView!
    
    var album: Album?
    
    func configure(album: Album) {
        self.album = album
        
        albumTitleLabel.text = album.title
        albumArtistLabel.text = album.artist
        coverImageView.image = album.cover
        
        songTableView.delegate = self
        songTableView.dataSource = self
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= albumTitleLabel.frame.maxY) {
            self.title = albumTitleLabel.text
        } else {
            self.title = ""
        }
    }
}

class SongCell: UITableViewCell {
    @IBOutlet var rowIndexLabel : UILabel?
    @IBOutlet var titleLabel : UILabel?
    @IBOutlet var artistLabel : UILabel?
    @IBOutlet weak var optionsButton: UIButton!
}

extension AlbumViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return album?.songs.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let songs = album?.songs ?? []
        let cell = songTableView.dequeueReusableCell(withIdentifier: "songCellType", for: indexPath) as! SongCell
        
        if indexPath.row >= songs.count { return cell }
        
        let song = songs[indexPath.row]
        
        cell.rowIndexLabel?.text = String(indexPath.row + 1)
        cell.titleLabel?.text = song.title
        cell.artistLabel?.text = song.artist
        
        return cell
    }
}

