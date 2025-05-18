
import Foundation
import UIKit
import CoreLocation

//Контроллер для отображения погоды
enum Section: Int, CaseIterable {
    case current, hourly, daily
}

struct SectionItem: Hashable {
    let id = UUID()
    let data: AnyHashable
}

final class WeatherViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let layout = makeLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.alwaysBounceVertical = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        
        cv.register(CurrentWeatherCell.self,
                    forCellWithReuseIdentifier: CurrentWeatherCell.reuseIdentifier)
        cv.register(HourlyForecastCell.self,
                    forCellWithReuseIdentifier: HourlyForecastCell.reuseIdentifier)
        cv.register(DailyForecastCell.self,
                    forCellWithReuseIdentifier: DailyForecastCell.reuseIdentifier)
        cv.register(DailySectionHeaderView.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: DailySectionHeaderView.reuseIdentifier)
        return cv
    }()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, SectionItem> = {
        let ds = UICollectionViewDiffableDataSource<Section, SectionItem>(collectionView: collectionView) { [weak self]
            (collectionView, indexPath, item) in
            guard let self = self,
                  let section = Section(rawValue: indexPath.section) else {
                return UICollectionViewCell()
            }
            switch section {
            case .current:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CurrentWeatherCell.reuseIdentifier,
                    for: indexPath) as? CurrentWeatherCell else {
                    return UICollectionViewCell()
                }
                if let weather = item.data as? CurrentWeatherResponse {
                    cell.configure(with: weather)
                }
                return cell
                
            case .hourly:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: HourlyForecastCell.reuseIdentifier,
                    for: indexPath) as? HourlyForecastCell else {
                    return UICollectionViewCell()
                }
                if let entry = item.data as? HourlyForecastEntry {
                    let isFirst = indexPath.item == 0
                    cell.configure(with: entry, isFirstHour: isFirst)
                }
                return cell
                
            case .daily:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: DailyForecastCell.reuseIdentifier,
                    for: indexPath) as? DailyForecastCell else {
                    return UICollectionViewCell()
                }
                if let day = item.data as? ForecastDay {
                    cell.configure(with: day)
                }
                return cell
            }
        }
        ds.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader,
                  let section = Section(rawValue: indexPath.section),
                  section == .daily else {
                return nil
            }
            return collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: DailySectionHeaderView.reuseIdentifier,
                for: indexPath) as? DailySectionHeaderView
        }
        return ds
    }()
    
    private var gradientLayer = CAGradientLayer()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // Вместо конкрентного типа — протокол
       private let viewModel: WeatherViewModelProtocol
       
       // Единственный designated initializer
       init(viewModel: WeatherViewModelProtocol) {
           self.viewModel = viewModel
           super.init(nibName: nil, bundle: nil)
       }
       @available(*, unavailable)
       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupAnimatedGradientBackground()
        setupCollectionViewConstraints()
        setupActivityIndicator()
        bindViewModel()
        viewModel.start()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    private func setupCollectionViewConstraints() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupGradientBackground() {
        gradientLayer.colors = [
            UIColor(red: 0.68, green: 0.85, blue: 0.90, alpha: 1.0).cgColor,
            UIColor(red: 0.96, green: 0.77, blue: 0.82, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupAnimatedGradientBackground() {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        
        gradientLayer.colors = [
            UIColor(red: 0.68, green: 0.85, blue: 0.90, alpha: 1.0).cgColor,
            UIColor(red: 0.96, green: 0.77, blue: 0.82, alpha: 1.0).cgColor
        ]
        
        view.layer.insertSublayer(gradientLayer, at: 0)
        self.gradientLayer = gradientLayer
        
        
        let animation = CABasicAnimation(keyPath: "colors")
        animation.duration = 5.0
        animation.fromValue = [
            UIColor(red: 0.68, green: 0.85, blue: 0.90, alpha: 1.0).cgColor,
            UIColor(red: 0.96, green: 0.77, blue: 0.82, alpha: 1.0).cgColor
        ]
        animation.toValue = [
            UIColor(red: 0.53, green: 0.81, blue: 0.92, alpha: 1.0).cgColor,
            UIColor(red: 0.58, green: 0.44, blue: 0.86, alpha: 1.0).cgColor
        ]
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        gradientLayer.add(animation, forKey: "colorChange")
    }
    
    private func bindViewModel() {
        viewModel.onLoadingChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                isLoading ? self?.activityIndicator.startAnimating()
                : self?.activityIndicator.stopAnimating()
            }
        }
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                let alert = UIAlertController(title: "Проблема с сетью",
                                              message: message,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Повторить",
                                              style: .default) { _ in
                    self?.viewModel.retryLastRequest()
                })
                self?.present(alert, animated: true)
            }
        }
        viewModel.onWeatherUpdate = { [weak self] current in
            DispatchQueue.main.async {
                var snapshot = NSDiffableDataSourceSnapshot<Section, SectionItem>()
                snapshot.appendSections([.current])
                snapshot.appendItems([SectionItem(data: AnyHashable(current))], toSection: .current)
                self?.dataSource.apply(snapshot, animatingDifferences: true)
            }
        }
        viewModel.onHourlyUpdate = { [weak self] entries in
            DispatchQueue.main.async {
                guard let self = self else { return }
                var snapshot = self.dataSource.snapshot()
                if !snapshot.sectionIdentifiers.contains(.hourly) {
                    snapshot.appendSections([.hourly])
                }
                snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .hourly))
                let items = entries.map { SectionItem(data: AnyHashable($0)) }
                snapshot.appendItems(items, toSection: .hourly)
                self.dataSource.apply(snapshot, animatingDifferences: true)
            }
        }
        viewModel.onDailyUpdate = { [weak self] days in
            DispatchQueue.main.async {
                guard let self = self else { return }
                var snapshot = self.dataSource.snapshot()
                if !snapshot.sectionIdentifiers.contains(.daily) {
                    snapshot.appendSections([.daily])
                }
                snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .daily))
                let items = days.map { SectionItem(data: AnyHashable($0)) }
                snapshot.appendItems(items, toSection: .daily)
                self.dataSource.apply(snapshot, animatingDifferences: true)
            }
        }
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            let section = Section(rawValue: sectionIndex)!
            switch section {
            case .current:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(200))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize,
                                                             subitems: [item])
                return NSCollectionLayoutSection(group: group)
            case .hourly:
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(60),
                                                      heightDimension: .absolute(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize,
                                                               subitems: [item])
                let sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.orthogonalScrollingBehavior = .continuous
                sectionLayout.interGroupSpacing = 8
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 16,
                                                                      leading: 16,
                                                                      bottom: 16,
                                                                      trailing: 16)
                return sectionLayout
            case .daily:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(60))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize,
                                                             subitems: [item])
                let sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.interGroupSpacing = 8
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 16,
                                                                      leading: 16,
                                                                      bottom: 16,
                                                                      trailing: 16)
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .absolute(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                         elementKind: UICollectionView.elementKindSectionHeader,
                                                                         alignment: .top)
                sectionLayout.boundarySupplementaryItems = [header]
                return sectionLayout
            }
        }
    }
}





