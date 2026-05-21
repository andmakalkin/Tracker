import UIKit

final class SearchTextFieldViewController: UIViewController {
    
    // MARK: - Delegate
    weak var delegate: SearchTextFieldViewControllerDelegateProtocol?
    
    // MARK: - UI Elements
    private lazy var searchTextField = UISearchTextField()
    
    // MARK: - State
    private var inputText: String = ""
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        
        setupView()
    }
    
    // MARK: - UI Setup
    private func setupView() {
        view.backgroundColor = .clear
        
        setupSearchTextField()
    }
    
    private func setupSearchTextField() {
        searchTextField.addTarget(
            self,
            action: #selector(searchTextDidChange),
            for: .editingChanged
        )
        
        searchTextField.backgroundColor = .ypSearchBar
        searchTextField.leftView?.tintColor = .ypGray
        
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: [
                .font: UIFont.systemFont(ofSize: 17, weight: .regular),
                .foregroundColor: UIColor.ypGray
            ]
        )
        
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.keyboardType = .default
        searchTextField.returnKeyType = .search
        
        searchTextField.borderStyle = .none
        
        view.addSubview(searchTextField)
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            searchTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            searchTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            searchTextField.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
        ])
    }
    
    // MARK: - Actions
    @objc private func searchTextDidChange() {
        inputText = searchTextField.text ?? ""
    }
    
    // MARK: - Public Methods
    func finishInputEditing() {
        view.endEditing(true)
        
        delegate?.didFinishInputEditing(inputText)
    }
}

// MARK: - UISearchTextFieldDelegate
extension SearchTextFieldViewController: UISearchTextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        finishInputEditing()
        return true
    }
}
