//
//  VideoPlaylistVC.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/16.
//

import UIKit

class VideoPlaylistVC: UIViewController {
    
    // MARK: - Properties
    
    private let videoCountContainerView = UIView()
    private var videoCountLabel: UILabel = {
        let lb = UILabel()
        lb.text = "플레이리스트 개수"
        return lb
    }()
    
    private let tableView = UITableView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    // MARK: - Actions
    
    
    
    // MARK: - Heleprs

    func setupLayout() {
        
        view.backgroundColor = .white
        setupTableView()
        setupContraints()
    }
    
    func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        let nibName = UINib(nibName: "BottomPlaylistTVCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "BottomPlaylistTVCell")
        tableView.rowHeight = 81
        tableView.tableFooterView = UIView()
    }
    
    func setupContraints() {
        
        videoCountContainerView.backgroundColor = .red
        view.addSubview(videoCountContainerView)
        videoCountContainerView.anchor(top: view.topAnchor,
                                       left: view.leftAnchor,
                                       right: view.rightAnchor,
                                       height: 47)
        view.addSubview(tableView)
        tableView.anchor(top: videoCountContainerView.bottomAnchor,
                         left: view.leftAnchor,
                         bottom: view.bottomAnchor,
                         right: view.rightAnchor)
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension VideoPlaylistVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BottomPlaylistTVCell.reusableIdentifier,
                                                       for: indexPath) as? BottomPlaylistTVCell else
        { return UITableViewCell() }
        return cell
    }
    
    
}
