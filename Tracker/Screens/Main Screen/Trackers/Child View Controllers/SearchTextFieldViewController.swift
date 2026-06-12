import UIKit

final class SearchTextFieldViewController: UIViewController {
    
    // MARK: - Delegate
    weak var delegate: SearchTextFieldViewControllerDelegateProtocol?
    
    // MARK: - UI Elements
    private lazy var horizontalStackView = UIStackView()
    private lazy var searchTextField = UISearchTextField()
    private lazy var cancelButton = UIButton(type: .system)
    
    // MARK: - State
    // Не нашёл в ТЗ чёткого описания поведения UI на случай,
    // если пользователь не подтвердит поиск после ввода текста.
    // Поэтому логика такая:
    //
    // `inputText` хранит текущее значение поля ввода,
    // `appliedSearchText` — последний подтверждённый поисковый запрос.
    //
    // - если пользователь ввёл текст и тапнул вне поля,
    //   клавиатура скрывается, текст остаётся в поле,
    //   кнопка "Отменить" скрывается, поиск не применяется;
    // - если пользователь нажал Search на клавиатуре,
    //   `inputText` сохраняется в `appliedSearchText`,
    //   передаётся наружу как поисковый фильтр,
    //   кнопка "Отменить" остаётся видимой для сброса поиска;
    // - если пользователь нажал "Отменить",
    //   поле ввода, `inputText` и `appliedSearchText` очищаются,
    //   кнопка "Отменить" скрывается,
    //   а главный экран получает пустую строку для сброса фильтра.
    
    private var inputText: String = ""
    private var appliedSearchText: String = ""
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        
        setupView()
    }
    
    // MARK: - UI Setup
    private func setupView() {
        view.backgroundColor = .clear
        
        setupHorizontalStackView()
        setupSearchTextField()
        setupCancelButton()
    }
    
    private func setupHorizontalStackView() {
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.distribution = .fill
        horizontalStackView.spacing = 5
        
        view.addSubview(horizontalStackView)
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            horizontalStackView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            horizontalStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            horizontalStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            horizontalStackView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
        ])
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
        searchTextField.layer.cornerRadius = 10
        searchTextField.layer.masksToBounds = true
        
        horizontalStackView.addArrangedSubview(searchTextField)
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchTextField.heightAnchor.constraint(
                equalToConstant: 36
            ),
        ])
    }
    
    private func setupCancelButton() {
        cancelButton.addTarget(
            self,
            action: #selector(cancelButtonDidTap),
            for: .touchUpInside
        )
        
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.ypBlue, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(
            ofSize: 17,
            weight: .regular
        )
        
        cancelButton.isHidden = true
        cancelButton.alpha = 0
        
        cancelButton.setContentHuggingPriority(
            .required,
            for: .horizontal
        )
        cancelButton.setContentCompressionResistancePriority(
            .required,
            for: .horizontal
        )
        
        horizontalStackView.addArrangedSubview(cancelButton)
    }
    
    // MARK: - Actions
    @objc private func searchTextDidChange() {
        inputText = searchTextField.text ?? ""
    }
    
    @objc private func cancelButtonDidTap() {
        inputText = ""
        appliedSearchText = ""
        
        searchTextField.text = ""
        searchTextField.resignFirstResponder()
        setCancelButtonHidden(true)
        
        delegate?.didFinishInputEditing(inputText)
    }
    
    // MARK: - Public Methods
    func finishInputEditing() {
        searchTextField.resignFirstResponder()
        
        appliedSearchText = inputText
        delegate?.didFinishInputEditing(inputText)
    }
    
    func hideKeyboard() {
        searchTextField.resignFirstResponder()
        
        if appliedSearchText.isEmpty {
            setCancelButtonHidden(true)
        }
    }
    
    // MARK: - Content State
    private func setCancelButtonHidden(_ isHidden: Bool) {
        guard cancelButton.isHidden != isHidden else {
            return
        }
        
        if isHidden {
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                options: [.curveEaseInOut]
            ) {
                self.cancelButton.alpha = 0
                self.cancelButton.isHidden = true
                self.view.layoutIfNeeded()
            }
        } else {
            cancelButton.alpha = 0
            cancelButton.isHidden = false
            
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                options: [.curveEaseInOut]
            ) {
                self.cancelButton.alpha = 1
                self.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: - UISearchTextFieldDelegate
extension SearchTextFieldViewController: UISearchTextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        finishInputEditing()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setCancelButtonHidden(false)
    }
}
