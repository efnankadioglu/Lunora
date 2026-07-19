//
//  BirthPlaceSearchViewController.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 19.07.2026.
//


import UIKit
import MapKit

final class BirthPlaceSearchViewController: UIViewController {

    // MARK: - Output

    var onPlaceSelected: ((BirthPlace) -> Void)?

    // MARK: - State

    private let searchCompleter = MKLocalSearchCompleter()
    private var searchResults: [MKLocalSearchCompletion] = []
    private var activeSearch: MKLocalSearch?

    // MARK: - Colors

    private enum Palette {
        static let background = UIColor(
            red: 255 / 255,
            green: 243 / 255,
            blue: 248 / 255,
            alpha: 1
        )

        static let primaryPink = UIColor(
            red: 232 / 255,
            green: 87 / 255,
            blue: 160 / 255,
            alpha: 1
        )

        static let titlePink = UIColor(
            red: 188 / 255,
            green: 83 / 255,
            blue: 140 / 255,
            alpha: 1
        )

        static let text = UIColor(
            red: 61 / 255,
            green: 37 / 255,
            blue: 51 / 255,
            alpha: 1
        )

        static let secondaryText = UIColor(
            red: 126 / 255,
            green: 99 / 255,
            blue: 116 / 255,
            alpha: 1
        )

        static let borderPink = UIColor(
            red: 247 / 255,
            green: 167 / 255,
            blue: 207 / 255,
            alpha: 1
        )
    }

    // MARK: - UI

    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        var configuration = UIButton.Configuration.plain()
        configuration.title = "Geri"
        configuration.image = UIImage(systemName: "chevron.left")
        configuration.imagePadding = 5
        configuration.contentInsets = .zero
        configuration.baseForegroundColor = Palette.titlePink

        button.configuration = configuration
        button.addTarget(
            self,
            action: #selector(backButtonTapped),
            for: .touchUpInside
        )

        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Doğum Yeri"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = Palette.text
        label.textAlignment = .center
        return label
    }()

    private let searchContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 19
        view.layer.borderWidth = 1
        view.layer.borderColor = Palette.borderPink.cgColor
        return view
    }()

    private let searchIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = Palette.primaryPink
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let searchTextField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "Şehir veya ülke ara"
        field.font = .systemFont(ofSize: 16)
        field.textColor = Palette.text
        field.autocorrectionType = .no
        field.autocapitalizationType = .words
        field.clearButtonMode = .whileEditing
        field.returnKeyType = .search
        return field
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text =
            "Doğduğun şehri sonuçlar arasından seç. Aynı isimli şehirleri ülke ve bölge bilgisine göre kontrol et."
        label.font = .systemFont(ofSize: 13)
        label.textColor = Palette.secondaryText
        label.numberOfLines = 0
        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorInset = UIEdgeInsets(
            top: 0,
            left: 58,
            bottom: 0,
            right: 20
        )
        tableView.keyboardDismissMode = .interactive
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        return tableView
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Şehir aramak için yukarıya yazmaya başla."
        label.font = .systemFont(ofSize: 15)
        label.textColor = Palette.secondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = Palette.primaryPink
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        configureSearch()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchTextField.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    deinit {
        activeSearch?.cancel()
        searchCompleter.cancel()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = Palette.background

        view.addSubview(headerView)
        view.addSubview(searchContainerView)
        view.addSubview(infoLabel)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        view.addSubview(loadingIndicator)

        headerView.addSubview(backButton)
        headerView.addSubview(titleLabel)

        searchContainerView.addSubview(searchIconImageView)
        searchContainerView.addSubview(searchTextField)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            BirthPlaceSearchCell.self,
            forCellReuseIdentifier: BirthPlaceSearchCell.reuseIdentifier
        )
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 12
            ),
            headerView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 24
            ),
            headerView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -24
            ),
            headerView.heightAnchor.constraint(equalToConstant: 58),

            backButton.leadingAnchor.constraint(
                equalTo: headerView.leadingAnchor,
                constant: 4
            ),
            backButton.centerYAnchor.constraint(
                equalTo: headerView.centerYAnchor
            ),

            titleLabel.centerXAnchor.constraint(
                equalTo: headerView.centerXAnchor
            ),
            titleLabel.centerYAnchor.constraint(
                equalTo: headerView.centerYAnchor
            ),

            searchContainerView.topAnchor.constraint(
                equalTo: headerView.bottomAnchor,
                constant: 20
            ),
            searchContainerView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 24
            ),
            searchContainerView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -24
            ),
            searchContainerView.heightAnchor.constraint(
                equalToConstant: 58
            ),

            searchIconImageView.leadingAnchor.constraint(
                equalTo: searchContainerView.leadingAnchor,
                constant: 18
            ),
            searchIconImageView.centerYAnchor.constraint(
                equalTo: searchContainerView.centerYAnchor
            ),
            searchIconImageView.widthAnchor.constraint(equalToConstant: 20),
            searchIconImageView.heightAnchor.constraint(equalToConstant: 20),

            searchTextField.leadingAnchor.constraint(
                equalTo: searchIconImageView.trailingAnchor,
                constant: 14
            ),
            searchTextField.trailingAnchor.constraint(
                equalTo: searchContainerView.trailingAnchor,
                constant: -16
            ),
            searchTextField.topAnchor.constraint(
                equalTo: searchContainerView.topAnchor
            ),
            searchTextField.bottomAnchor.constraint(
                equalTo: searchContainerView.bottomAnchor
            ),

            infoLabel.topAnchor.constraint(
                equalTo: searchContainerView.bottomAnchor,
                constant: 12
            ),
            infoLabel.leadingAnchor.constraint(
                equalTo: searchContainerView.leadingAnchor,
                constant: 4
            ),
            infoLabel.trailingAnchor.constraint(
                equalTo: searchContainerView.trailingAnchor,
                constant: -4
            ),

            tableView.topAnchor.constraint(
                equalTo: infoLabel.bottomAnchor,
                constant: 14
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            tableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),

            emptyStateLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            emptyStateLabel.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            emptyStateLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor,
                constant: 40
            ),
            emptyStateLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor,
                constant: -40
            ),

            loadingIndicator.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            loadingIndicator.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            )
        ])
    }

    private func configureSearch() {
        searchCompleter.delegate = self
        searchCompleter.resultTypes = [.address]

        searchTextField.addTarget(
            self,
            action: #selector(searchTextChanged),
            for: .editingChanged
        )
    }

    // MARK: - Search

    @objc private func searchTextChanged() {
        let query = searchTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard query.count >= 2 else {
            searchCompleter.queryFragment = ""
            searchResults = []
            tableView.reloadData()
            updateEmptyState()
            return
        }

        searchCompleter.queryFragment = query
    }

    private func resolvePlace(
        from completion: MKLocalSearchCompletion
    ) {
        activeSearch?.cancel()

        loadingIndicator.startAnimating()
        tableView.isUserInteractionEnabled = false

        let request = MKLocalSearch.Request(completion: completion)
        request.resultTypes = [.address]

        let search = MKLocalSearch(request: request)
        activeSearch = search

        search.start { [weak self] response, error in
            DispatchQueue.main.async {
                guard let self else { return }

                self.loadingIndicator.stopAnimating()
                self.tableView.isUserInteractionEnabled = true

                if let error {
                    self.showAlert(
                        title: "Konum bulunamadı",
                        message: error.localizedDescription
                    )
                    return
                }

                guard let mapItem = response?.mapItems.first else {
                    self.showAlert(
                        title: "Konum bulunamadı",
                        message: "Bu sonuç için doğrulanabilir bir konum bilgisi bulunamadı."
                    )
                    return
                }

                do {
                    let birthPlace = try self.makeBirthPlace(
                        from: mapItem
                    )

                    self.onPlaceSelected?(birthPlace)
                    self.navigationController?
                        .popViewController(animated: true)

                } catch {
                    self.showAlert(
                        title: "Konum doğrulanamadı",
                        message: error.localizedDescription
                    )
                }
            }
        }
    }

    private func makeBirthPlace(
        from mapItem: MKMapItem
    ) throws -> BirthPlace {
        let placemark = mapItem.placemark

        let city = cleaned(
            placemark.locality
                ?? placemark.subAdministrativeArea
                ?? placemark.administrativeArea
                ?? mapItem.name
        )

        guard let city else {
            throw BirthPlaceSearchError.missingCity
        }

        guard let country = cleaned(placemark.country) else {
            throw BirthPlaceSearchError.missingCountry
        }

        let coordinate = placemark.coordinate

        guard CLLocationCoordinate2DIsValid(coordinate) else {
            throw BirthPlaceSearchError.invalidCoordinates
        }

        guard let timeZone = mapItem.timeZone
                ?? placemark.timeZone,
              TimeZone(identifier: timeZone.identifier) != nil else {
            throw BirthPlaceSearchError.missingTimeZone
        }

        return BirthPlace(
            city: city,
            administrativeArea: cleaned(
                placemark.administrativeArea
            ),
            country: country,
            countryCode: cleaned(
                placemark.isoCountryCode
            )?.uppercased(),
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            timeZoneIdentifier: timeZone.identifier,
            placeIdentifier: nil
        )
    }

    private func cleaned(_ value: String?) -> String? {
        guard let value else {
            return nil
        }

        let trimmed = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        return trimmed.isEmpty ? nil : trimmed
    }

    private func updateEmptyState() {
        let query = searchTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if query.count < 2 {
            emptyStateLabel.text =
                "Şehir aramak için yukarıya yazmaya başla."
            emptyStateLabel.isHidden = false
            return
        }

        emptyStateLabel.text =
            "Bu aramayla eşleşen bir yer bulunamadı."
        emptyStateLabel.isHidden = !searchResults.isEmpty
    }

    // MARK: - Navigation

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Alert
    
    private func showSaveSuccessAlert() {
        let alert = UIAlertController(
            title: "Bilgiler kaydedildi",
            message: "Doğum bilgilerin başarıyla güncellendi.",
            preferredStyle: .alert
        )

        let confirmAction = UIAlertAction(
            title: "Tamam",
            style: .default
        ) { [weak self] _ in
            guard let self else { return }

            self.navigationController?
                .popViewController(animated: true)
        }

        alert.addAction(confirmAction)
        present(alert, animated: true)
    }

    private func showAlert(
        title: String,
        message: String
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Tamam",
                style: .default
            )
        )

        present(alert, animated: true)
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension BirthPlaceSearchViewController:
    MKLocalSearchCompleterDelegate {

    func completerDidUpdateResults(
        _ completer: MKLocalSearchCompleter
    ) {
        searchResults = completer.results
        tableView.reloadData()
        updateEmptyState()
    }

    func completer(
        _ completer: MKLocalSearchCompleter,
        didFailWithError error: Error
    ) {
        searchResults = []
        tableView.reloadData()
        updateEmptyState()
    }
}

// MARK: - UITableViewDataSource

extension BirthPlaceSearchViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        searchResults.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: BirthPlaceSearchCell.reuseIdentifier,
            for: indexPath
        ) as? BirthPlaceSearchCell else {
            return UITableViewCell()
        }

        cell.configure(with: searchResults[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension BirthPlaceSearchViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(
            at: indexPath,
            animated: true
        )

        resolvePlace(
            from: searchResults[indexPath.row]
        )
    }
}

// MARK: - Cell

private final class BirthPlaceSearchCell: UITableViewCell {

    static let reuseIdentifier = "BirthPlaceSearchCell"

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "location")
        imageView.tintColor = UIColor(
            red: 232 / 255,
            green: 87 / 255,
            blue: 160 / 255,
            alpha: 1
        )
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(
            red: 61 / 255,
            green: 37 / 255,
            blue: 51 / 255,
            alpha: 1
        )
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        label.textColor = UIColor(
            red: 126 / 255,
            green: 99 / 255,
            blue: 116 / 255,
            alpha: 1
        )
        label.numberOfLines = 0
        return label
    }()

    private lazy var labelsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 4
        return stack
    }()

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .default

        contentView.addSubview(iconImageView)
        contentView.addSubview(labelsStackView)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 24
            ),
            iconImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 18
            ),
            iconImageView.widthAnchor.constraint(
                equalToConstant: 22
            ),
            iconImageView.heightAnchor.constraint(
                equalToConstant: 22
            ),

            labelsStackView.leadingAnchor.constraint(
                equalTo: iconImageView.trailingAnchor,
                constant: 14
            ),
            labelsStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -24
            ),
            labelsStackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 14
            ),
            labelsStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -14
            )
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        with completion: MKLocalSearchCompletion
    ) {
        titleLabel.text = completion.title

        let subtitle = completion.subtitle
            .trimmingCharacters(in: .whitespacesAndNewlines)

        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle.isEmpty
    }
}

// MARK: - Errors

private enum BirthPlaceSearchError: LocalizedError {
    case missingCity
    case missingCountry
    case invalidCoordinates
    case missingTimeZone

    var errorDescription: String? {
        switch self {
        case .missingCity:
            return "Seçilen sonucun şehir bilgisi bulunamadı."

        case .missingCountry:
            return "Seçilen sonucun ülke bilgisi bulunamadı."

        case .invalidCoordinates:
            return "Seçilen sonucun koordinatları doğrulanamadı."

        case .missingTimeZone:
            return "Seçilen yerin saat dilimi doğrulanamadı. Lütfen başka bir sonuç seç."
        }
    }
}
