
import UIKit
import MediaPlayer

class LibraryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var albumCollectionView: UICollectionView!
    
    var musicQuery: MusicQuery = MusicQuery()
    var albums: [Album] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        albumCollectionView.dataSource = self
        albumCollectionView.delegate = self
        
        MPMediaLibrary.requestAuthorization { (status) in
            if status == .authorized {
                self.albums = self.musicQuery.albums()
                DispatchQueue.main.async {
                    self.albumCollectionView.reloadData()
                }
            } else {
                print("Media Error: \(status)")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        
        if let albumCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as? AlbumCollectionViewCell {
            albumCell.configure(album: albums[indexPath.row])
            cell = albumCell
        }
        
        return cell
    }
    
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let album = albums[indexPath.row]
//        
//        let albumViewController = self.storyboard?.instantiateViewController(withIdentifier: "AlbumViewController") as! AlbumViewController
//        albumViewController.configure(album: album)
//    
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showAlbum") {
            let album = (sender as! AlbumCollectionViewCell).album
            let albumViewController = segue.destination as! AlbumViewController
            let _ = albumViewController.view
            albumViewController.configure(album: album!)
        }
    }
}

@IBDesignable extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
            get { return layer.cornerRadius }
            set {
                  layer.cornerRadius = newValue

                  // If masksToBounds is true, subviews will be
                  // clipped to the rounded corners.
                  layer.masksToBounds = (newValue > 0)
            }
        }
}

@IBDesignable extension UIView {
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let cgColor = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: cgColor)
        }
        set { layer.borderColor = newValue?.cgColor }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
}

struct Song {
    let id = UUID()
    let title: String
    let artist: String
    let albumId: UUID
}

struct Album {
    let id: UUID
    let title: String
    let artist: String
    let songs: [Song]
    let cover: UIImage?
}

class MusicQuery {
    
    func albums() -> [Album] {
        
        var albums: [Album] = []
        
        let albumsQuery = MPMediaQuery.albums()
        let albumItemCollection: [MPMediaItemCollection] = albumsQuery.collections! as [MPMediaItemCollection]
        
        for album in albumItemCollection {
            let albumItems: [MPMediaItem] = album.items as [MPMediaItem]
            let first = albumItems.first
            
            let albumId = UUID()
            let albumTitle = first?.albumTitle ?? ""
            let albumArtist = first?.albumArtist ?? ""
            let albumCover = first?.artwork?.image(at: CGSize(width: 500, height: 500))
            
            var songs: [Song] = []
            
            for song in albumItems {
                let songData = Song(title: song.title ?? "", artist: song.artist ?? "", albumId: albumId)
                
                songs.append(songData)
            }
            
            let albumData = Album(id: albumId, title: albumTitle, artist: albumArtist, songs: songs, cover: albumCover)
            
            albums.append(albumData)
        }
        
        return albums
    }
}
