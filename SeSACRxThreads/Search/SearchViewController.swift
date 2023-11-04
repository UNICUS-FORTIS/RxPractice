//
//  SearchViewController.swift
//  SeSACRxThreads
//
//  Created by LOUIE MAC on 11/4/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SampleViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .cyan
        title = "\(Int.random(in: 1...100))"
    }
    
}

class SearchViewController: UIViewController {

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
        tv.backgroundColor = .white
        tv.rowHeight = 180
        tv.separatorStyle = .none
        return tv
    }()
    
    let searchBar = UISearchBar()
    
    var data = ["A", "B", "C", "D", "E", "SS", "SA", "SR", "SSR"]
    lazy var items = BehaviorSubject(value: data)
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        configure()
        bind()
        setSearchController()
    }
    
    func bind() {
        items
            .bind(to: tableView.rx.items(cellIdentifier: SearchTableViewCell.identifier,
                                         cellType: SearchTableViewCell.self)) { (row, element,cell) in
                cell.appNameLabel.text = element
                cell.appIconImageView.backgroundColor = .green
                cell.downloadButton.rx.tap
                    .subscribe(with: self) { owner, value in
                        owner.navigationController?.pushViewController(SampleViewController(), animated: true)
                    }
                    .disposed(by: cell.disposeBag)
            }.disposed(by: disposeBag)
        
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(String.self))
            .map { "셀 선택 \($0), \($0)" }
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked
            .withLatestFrom(searchBar.rx.text.orEmpty) { void, text in
                return text
            }
            .distinctUntilChanged()
            .subscribe(with: self) { owner, text in
                owner.data.insert(text, at: 0)
                owner.items.onNext(owner.data)
            }
            .disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(with: self) { owner, value in
                let result = value == "" ? owner.data : owner.data.filter { $0.contains(value) }
                owner.items.onNext(result)
            }.disposed(by: disposeBag)
    }
    

    private func setSearchController() {
        view.addSubview(searchBar)
        self.navigationItem.titleView = searchBar
    }
    
    
    private func configure() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
    }

}
