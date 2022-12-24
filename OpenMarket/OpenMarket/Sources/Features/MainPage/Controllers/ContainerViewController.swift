//
//  ItemContainerViewController.swift
//  OpenMarket
//
//  Created by minsson on 2022/08/03.
//

import UIKit

final class ContainerViewController: UIViewController {
    
    // MARK: - Private Enums
    
    private enum DisplayingViewType: Int {
        case list = 0
        case grid = 1
    }
    
    // MARK: - Properties
    
    private let segmentedControl: UISegmentedControl = {
        let selectionItems = [
            UIImage(systemName: "rectangle.grid.1x2"),
            UIImage(systemName: "square.grid.2x2")
        ]
        
        let segmentedControl = UISegmentedControl(items: selectionItems as [Any])
        segmentedControl.selectedSegmentIndex = DisplayingViewType.list.rawValue
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    private lazy var listCollectionViewController: ListCollectionViewController = {
        let listCollectionViewController = ListCollectionViewController()
        return listCollectionViewController
    }()
    
    private lazy var gridCollectionViewController: GridCollectionViewController = {
        let gridCollectionViewController = GridCollectionViewController()
        gridCollectionViewController.view.isHidden = true
        return gridCollectionViewController
    }()
    
    private lazy var itemRegistrationViewController: ItemRegistrationViewController = {
        let itemRegistrationViewController = ItemRegistrationViewController()
        itemRegistrationViewController.view.backgroundColor = .white
        itemRegistrationViewController.title = "상품 등록"
        return itemRegistrationViewController
    }()
    
    private let floatingButtonWithActionSheet: UIButton = {
        let floatingButtonForActionSheet = UIButton()
        
        floatingButtonForActionSheet.layer.cornerRadius = 30
        floatingButtonForActionSheet.layer.shadowOpacity = 0.1
        
        floatingButtonForActionSheet.backgroundColor = .systemPurple
        floatingButtonForActionSheet.tintColor = .white
        
        floatingButtonForActionSheet.setImage(UIImage(systemName: "plus"), for: .normal)
        
        return floatingButtonForActionSheet
    }()
    
    private lazy var actionSheetForFloatingButton: UIAlertController = {
        let actionSheetForFloatingButton = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        return actionSheetForFloatingButton
    }()
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubViewToViewController()
        setupUIComponentsLayout()
        
        setupActionSheetForFloatingButton()
        setupTargetForSegmentedControl()
        setupTargetForFloatingButtonWithActionSheet()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

// MARK: - Private Actions

private extension ContainerViewController {
    
    // MARK: Actions for Adding UIComponents
    
    func addSubViewToViewController() {
        view.addSubview(listCollectionViewController.view)
        view.addSubview(gridCollectionViewController.view)
        view.addSubview(segmentedControl)
        view.addSubview(floatingButtonWithActionSheet)
        
        addChild(listCollectionViewController)
        addChild(gridCollectionViewController)
        
        listCollectionViewController.didMove(toParent: self)
        gridCollectionViewController.didMove(toParent: self)
    }
    
    // MARK: Actions for Segmented Control
    
    func setupTargetForSegmentedControl() {
        segmentedControl.addTarget(
            self,
            action: #selector(switchLayout),
            for: .valueChanged
        )
    }
    
    @objc func switchLayout(segmentedControl: UISegmentedControl) {
        switch DisplayingViewType(rawValue: segmentedControl.selectedSegmentIndex) {
        case .list:
            gridCollectionViewController.view.isHidden = true
            listCollectionViewController.view.isHidden = false
        case .grid:
            gridCollectionViewController.view.isHidden = false
            listCollectionViewController.view.isHidden = true
        case .none:
            break
        }
    }
    
    // MARK: Actions for Auto Layout
    
    func setupUIComponentsLayout() {
        setupSegmentedControlLayout()
        setupListCollectionViewLayout()
        setupGridCollectionViewLayout()
        setupFloatingButtonLayout()
    }
    
    func setupSegmentedControlLayout() {
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 8
            ),
            segmentedControl.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 120
            ),
            segmentedControl.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -120
            )
        ])
    }
    
    func setupListCollectionViewLayout() {
        listCollectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            listCollectionViewController.view.topAnchor.constraint(
                equalTo: segmentedControl.bottomAnchor,
                constant: 24
            ),
            listCollectionViewController.view.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -5
            ),
            listCollectionViewController.view.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 5
            ),
            listCollectionViewController.view.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -5
            )
        ])
    }
    
    func setupGridCollectionViewLayout() {
        gridCollectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gridCollectionViewController.view.topAnchor.constraint(
                equalTo: segmentedControl.bottomAnchor,
                constant: 24
            ),
            gridCollectionViewController.view.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -5
            ),
            gridCollectionViewController.view.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 5
            ),
            gridCollectionViewController.view.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -5
            )
        ])
    }
    
    func setupFloatingButtonLayout() {
        floatingButtonWithActionSheet.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            floatingButtonWithActionSheet.widthAnchor.constraint(equalToConstant: 60),
            floatingButtonWithActionSheet.heightAnchor.constraint(equalToConstant: 60),
            
            floatingButtonWithActionSheet.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            floatingButtonWithActionSheet.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }
    
    // MARK: - Actions for Floating Button with Action Sheet
    
    func setupTargetForFloatingButtonWithActionSheet() {
        floatingButtonWithActionSheet.addTarget(
            self,
            action: #selector(showActionSheet),
            for: .touchUpInside
        )
    }
    
    @objc func showActionSheet() {
        self.present(actionSheetForFloatingButton, animated: true)
    }
    
    // MARK: - Actions for ActionSheet
    
    func setupActionSheetForFloatingButton() {
        let itemRegistrationAction = UIAlertAction(
            title: "상품 등록",
            style: .default,
            handler: { _ in
                let itemRegistrationViewController = ItemRegistrationViewController()
                itemRegistrationViewController.modalPresentationStyle = .fullScreen
                self.present(itemRegistrationViewController, animated: true)
            }
        )
        
        let itemEditingAction = UIAlertAction(
            title: "상품 수정",
            style: .default,
            handler: { _ in
                // TODO: 수정페이지로 이동하는 코드 구현
            }
        )
        
        let cancelAction = UIAlertAction(
            title: "취소",
            style: .cancel
        )
        
        [itemRegistrationAction, itemEditingAction, cancelAction].forEach {
            actionSheetForFloatingButton.addAction($0)
        }
    }
}
