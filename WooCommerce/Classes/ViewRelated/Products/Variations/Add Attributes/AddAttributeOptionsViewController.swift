import UIKit
import Yosemite

final class AddAttributeOptionsViewController: UIViewController {

    @IBOutlet weak private var tableView: UITableView!

    private let viewModel: AddAttributeOptionsViewModel

    /// Keyboard management
    ///
    private lazy var keyboardFrameObserver: KeyboardFrameObserver = KeyboardFrameObserver { [weak self] keyboardFrame in
        self?.handleKeyboardFrameUpdate(keyboardFrame: keyboardFrame)
    }

    /// Init
    ///
    init(viewModel: AddAttributeOptionsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureMainView()
        configureTableView()
        registerTableViewHeaderSections()
        registerTableViewCells()
        startListeningToNotifications()
        observeViewModel()
        renderViewModel()
    }
}

// MARK: - View Configuration
//
private extension AddAttributeOptionsViewController {

    func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: Localization.nextNavBarButton,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(doneButtonPressed))
        removeNavigationBackBarButtonText()
    }

    func configureMainView() {
        view.backgroundColor = .listBackground
    }

    func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.backgroundColor = .listBackground

        tableView.dataSource = self
        tableView.delegate = self
    }

    func registerTableViewHeaderSections() {
        let headerNib = UINib(nibName: TwoColumnSectionHeaderView.reuseIdentifier, bundle: nil)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: TwoColumnSectionHeaderView.reuseIdentifier)
    }

    func registerTableViewCells() {
        tableView.registerNib(for: BasicTableViewCell.self)
        tableView.registerNib(for: TextFieldTableViewCell.self)
    }

    func observeViewModel() {
        viewModel.onChange = { [weak self] in
            guard let self = self else { return }
            self.renderViewModel()
        }
    }

    func renderViewModel() {
        title = viewModel.titleView
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.isNextButtonEnabled
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource Conformance
//
extension AddAttributeOptionsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = viewModel.sections[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier, for: indexPath)
        configure(cell, for: row, at: indexPath)

        return cell
    }
}

// MARK: - UITableViewDelegate Conformance
//
extension AddAttributeOptionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let leftText = viewModel.sections[section].header else {
            return nil
        }

        let headerID = TwoColumnSectionHeaderView.reuseIdentifier
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerID) as? TwoColumnSectionHeaderView else {
            assertionFailure("Could not find section header view for reuseIdentifier \(headerID)")
            return nil
        }

        headerView.leftText = leftText
        headerView.rightText = nil

        return headerView
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return viewModel.sections[section].footer
    }
}

// MARK: - Cell configuration
//
private extension AddAttributeOptionsViewController {
    /// Cells currently configured in the order they appear on screen
    ///
    func configure(_ cell: UITableViewCell, for row: Row, at indexPath: IndexPath) {
        switch (row, cell) {
        case (.termTextField, let cell as TextFieldTableViewCell):
            configureTextField(cell: cell)
        case (let .selectedTerms(name), let cell as BasicTableViewCell):
            configureOption(cell: cell, text: name)
        case (.existingTerms, let cell as BasicTableViewCell):
            configureOption(cell: cell, text: "Work in Progress")
        default:
            fatalError("Unsupported Cell")
            break
        }
    }

    func configureTextField(cell: TextFieldTableViewCell) {
        let viewModel = TextFieldTableViewCell.ViewModel(text: nil,
                                                         placeholder: Localization.optionNameCellPlaceholder,
                                                         onTextChange: nil,
                                                         onTextDidBeginEditing: nil,
                                                         onTextDidReturn: { [weak self] text in
                                                            if let text = text {
                                                                self?.viewModel.addNewOption(name: text)
                                                            }
                                                         }, inputFormatter: nil,
                                                         keyboardType: .default)
        cell.configure(viewModel: viewModel)
        cell.applyStyle(style: .body)
    }

    func configureOption(cell: BasicTableViewCell, text: String) {
        cell.textLabel?.text = text
    }
}

// MARK: - Keyboard management
//
private extension AddAttributeOptionsViewController {
    /// Registers for all of the related Notifications
    ///
    func startListeningToNotifications() {
        keyboardFrameObserver.startObservingKeyboardFrame()
    }
}

extension AddAttributeOptionsViewController: KeyboardScrollable {
    var scrollable: UIScrollView {
        return tableView
    }
}


// MARK: - Navigation actions handling
//
extension AddAttributeOptionsViewController {

    @objc private func doneButtonPressed() {
        // TODO: to be implemented
    }
}

extension AddAttributeOptionsViewController {

    struct Section: Equatable {
        let header: String?
        let footer: String?
        let rows: [Row]
    }

    enum Row: Equatable {
        case termTextField
        case selectedTerms(name: String)
        case existingTerms

        fileprivate var type: UITableViewCell.Type {
            switch self {
            case .termTextField:
                return TextFieldTableViewCell.self
            case .selectedTerms, .existingTerms:
                return BasicTableViewCell.self
            }
        }

        fileprivate var reuseIdentifier: String {
            return type.reuseIdentifier
        }
    }
}

private extension AddAttributeOptionsViewController {
    enum Localization {
        static let nextNavBarButton = NSLocalizedString("Next", comment: "Next nav bar button title in Add Product Attribute Options screen")
        static let optionNameCellPlaceholder = NSLocalizedString("Option name",
                                                            comment: "Placeholder of cell presenting the title of the new attribute option.")
    }
}
