//
//  MainViewController.swift
//  music
//
//  Created by Adrian Gomes on 3/17/24.
//

import UIKit

class MainViewController: UIViewController {
    
    var miniPlayer: MiniPlayerViewController?
    var tabController: UITabBarController?
    
    var library: LibraryViewController?
    
    var albumLoop = Loop<Song>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let list = [1, 2, 3, 4, 5]
        var loop = Loop<Int>()
        loop.append(list)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "embededMiniPlayer":
            miniPlayer = segue.destination as? MiniPlayerViewController
        case "embededTabController":
            tabController = segue.destination as? UITabBarController
        default:
            break
        }
    }
    
    func play(song: Song) {
        miniPlayer?.configure(song: song)
        let album = library?.albums.filter { $0.id == song.albumId }
        albumLoop.replace(album!.first!.songs)
        // FIXME: should start at song selected not first in album selected
        // albumLoop.balancedShuffle()
        print(albumLoop.description)
    }
}

class Node<T: Equatable>: Equatable {
    var value: T!
    var next: Node<T>?
    var prev: Node<T>?
    
    public init(_ value: T) {
        self.value = value
    }
    
    static func ==(lhs: Node<T>, rhs: Node<T>) -> Bool {
        return  lhs.value == rhs.value
    }

    public var description: String { "\(value!)" }
}

struct Loop<T: Equatable> {
    private var head: Node<T>?
    
    public var isEmpty: Bool { head == nil }
    public var count: Int = 0
    public var first: Node<T>? { head }
    
    public mutating func append(_ value: T) {
        let newNode = Node<T>(value)
        
        if (self.isEmpty) {
            newNode.next = newNode
            newNode.prev = newNode
            self.head = newNode
        } else {
            let last = self.head!.prev!
            newNode.next = self.head
            newNode.prev = last
            self.head!.prev = newNode
            last.next = newNode
        }
        
        self.count += 1
    }
    
    public mutating func append(_ values: [T]) {
        for value in values { self.append(value) }
    }
    
    public mutating func replace( _ values: [T]) {
        self.clear()
        self.append(values)
    }
    
    public mutating func insertAfter(_ value: T, prev: Node<T>?) {
        if (prev == nil) { return }
        
        let newNode = Node(value)
        newNode.prev = prev
        newNode.next = prev!.next
        prev!.next!.prev = newNode
        prev!.next! = newNode
        
        self.count += 1
    }
    
    public mutating func shift() -> T? {
        if (self.isEmpty) { return nil }
        
        let value = self.head!.value
        
        if (self.head == self.head!.next) {
            self.head = nil
        } else {
            self.head!.prev!.next = self.head!.next
            self.head!.next!.prev = self.head!.prev
            self.head = self.head!.next
        }
        
        self.count -= 1
        return value
    }
    
    public mutating func remove(_ value: T) -> T? {
        if let node = self.search(value) {
            if (node == self.head) { return self.shift() }
            
            node.prev!.next = node.next
            node.next!.prev = node.prev
            
            self.count -= 1
            return value;
        }
        
        return nil
    }
    
    public mutating func clear() {
        self.head = nil
        self.count = 0
    }
    
    public func search(_ value: T) -> Node<T>? {
        if (self.isEmpty) { return nil }
        if (self.head!.value == value) { return self.head }
        
        var curr = self.head!
        var rcurr = self.head!.prev!
        
        repeat {
            if (curr.value == value) { return curr }
            if (rcurr.value == value) { return rcurr }
            
            curr = curr.next!
            rcurr = rcurr.prev!
        } while (curr.prev != rcurr)
        
        return nil
    }
    
    public mutating func swap(_ a: Node<T>, _ b: Node<T>) {
        let temp = a.value
        a.value = b.value
        b.value = temp
    }
    
    public mutating func shuffle() {
        if (self.isEmpty) { return }
        
        var curr = self.head!.prev!
        while (curr != self.head) {
            let rand = Int.random(in: 1..<self.count)
            
            var temp = curr.prev!
            for _ in 1...rand { temp = temp.prev! }
            
            self.swap(curr, temp)
            
            curr = curr.prev!
        }
    }
}

extension Loop where T == Song {
    var description: String {
        if (self.isEmpty) { return "empty" }
        
        var desc = "head(\(self.head!.value!.title))"
        var curr = self.head!.next!
        
        while (curr != self.head) {
            desc += "<-->\(curr.value!.title)"
            curr = curr.next!
        }
        
        return desc
    }
    
    // Balanced Shuffle inspired by the spotify shuffle with a modified merge
    // algorithm that condenses the spread step in merge below
    // https://engineering.atspotify.com/2014/02/how-to-shuffle-songs/
    
    mutating func balancedShuffle() {
        var grouped = [String: [UUID: [Song]]]()
        var groupCount = 0
        
        var curr = self.head!
        repeat {
            let song = curr.value!
            let artist = song.albumArtist
            let album = song.albumId
            
            if (grouped[artist] == nil) {
                grouped[artist] = [album:[song]]
            } else if (grouped[artist]![album] == nil) {
                grouped[artist]![album] = [song]
            } else {
                grouped[artist]![album]!.append(song)
            }
            
            groupCount += 1
            curr = curr.next!
        } while (curr != self.head)
        
        let artists = grouped.values.map {
            let albums = $0.values.map { $0.shuffled() }
            return merge(albums, maxcount: groupCount)
        }
        let shuffled = merge(artists, maxcount: groupCount)
        
        self.replace(shuffled)
    }
    
    // Merge algorithm from:
    // https://cs.stackexchange.com/questions/29709/algorithm-to-distribute-items-evenly
    
    private struct Item {
        let list: [T]
        var count: Int
        let frequency: Double
        var priority: Double
        
        init(list: [T], maxcount: Int) {
            self.list = list
            self.count = list.count
            self.frequency = Double(maxcount / count)
            self.priority = self.frequency / 2
        }
        
        var description: String { "\((list, count, frequency, priority))" }
    }
    
    private func merge(_ groups: [[T]], maxcount: Int) -> [T] {
        var merged = [T]()
        
        var heap = [Item]()
        for i in 0..<groups.count {
            heap.append(Item(list: groups[i], maxcount: maxcount))
        }
        
        heap.sort { $0.priority < $1.priority }
        while (!heap.isEmpty && merged.count < maxcount) {
            var item = heap.removeFirst()
            if (item.count > 0) {
                 merged.append(item.list[item.count - 1])
                 item.count -= 1
                 item.priority += item.frequency
                 if (item.count > 0) { heap.append(item) }
            }
            
            heap.sort { $0.priority < $1.priority }
        }
        
        let offset = Int.random(in: 0..<merged.count)
        merged = Array(merged[offset...]) + merged[0..<offset]
        
        return merged
    }
}
