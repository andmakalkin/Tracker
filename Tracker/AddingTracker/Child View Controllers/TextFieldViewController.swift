import UIKit

final class TextFieldViewController: UIViewController {
    
    // MARK: - Delegate
    weak var delegate: TextFieldViewControllerDelegateProtocol?
    
    // MARK: - UI Elements
    private lazy var stackView = UIStackView()
    
    private lazy var textField = UITextField()
    
    private lazy var warningLabelContainerView = UIView()
    private lazy var warningLabel = UILabel()
    
    // MARK: - Data
    private let maxCharacters = 38
    private let placeholderText: String
    
    // MARK: - State
    private var inputText: String = ""
    
    // MARK: - Initialization
    init(placeholderText: String) {
        self.placeholderText = placeholderText
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        
        setupView()
    }
    
    // MARK: - UI Setup
    private func setupView() {
        setupStackView()
        setupTextField()
        setupWarningLabelContainerView()
    }
    
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(warningLabelContainerView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            stackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            stackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            stackView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
        ])
    }
    
    private func setupTextField() {
        textField.addTarget(
            self,
            action: #selector(textDidChange),
            for: .editingChanged
        )
        
        textField.textColor = .ypBlack
        textField.backgroundColor = .ypBackground
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 17, weight: .regular),
                .foregroundColor: UIColor.ypGray,
            ]
        )
        
        textField.clearButtonMode = .whileEditing
        textField.keyboardType = .default
        textField.returnKeyType = .go
        
        let paddingView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 16,
                height: 75
            )
        )
        
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(
                equalToConstant: 75
            ),
        ])
    }
    
    private func setupWarningLabelContainerView() {
        warningLabel.text = "Ограничение \(maxCharacters) символов"
        warningLabel.textColor = .ypRed
        warningLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        warningLabel.textAlignment = .center
        
        warningLabelContainerView.addSubview(warningLabel)
        
        warningLabelContainerView.translatesAutoresizingMaskIntoConstraints = false
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            warningLabel.topAnchor.constraint(
                equalTo: warningLabelContainerView.topAnchor,
                constant: 8
            ),
            warningLabel.bottomAnchor.constraint(
                equalTo: warningLabelContainerView.bottomAnchor,
                constant: -8
            ),
            warningLabel.centerXAnchor.constraint(
                equalTo: warningLabelContainerView.centerXAnchor
            ),
        ])
        
        warningLabelContainerView.isHidden = true
    }
    
    // MARK: - Actions
    @objc private func textDidChange() {
        inputText = textField.text ?? ""
        warningLabelContainerView.isHidden = inputText.count <= maxCharacters
    }
    
    // MARK: - Public Methods
    func finishInputEditing() {
        view.endEditing(true)
        warningLabelContainerView.isHidden = true
        delegate?.didFinishInputEditing(inputText)
    }
    
    // MARK: - Helpers
    private func shouldAllowTextChange(
        in textField: UITextField,
        range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = textField.text ?? ""
        
        guard let textRange = Range(range, in: currentText) else {
            return false
        }
        
        let updatedText = currentText.replacingCharacters(
            in: textRange,
            with: string
        )
        
        let isUnderLimit = updatedText.count <= maxCharacters
        warningLabelContainerView.isHidden = isUnderLimit
        
        return isUnderLimit
    }
}

// MARK: - UITextFieldDelegate
extension TextFieldViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        finishInputEditing()
        return true
    }
    
    @available(iOS 26.0, *)
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersInRanges ranges: [NSValue],
        replacementString string: String
    ) -> Bool {
        guard let range = ranges.first?.rangeValue else {
            return true
        }
        
        return shouldAllowTextChange(
            in: textField,
            range: range,
            replacementString: string
        )
    }
    
    @available(iOS, introduced: 2.0, deprecated: 26.0)
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        shouldAllowTextChange(
            in: textField,
            range: range,
            replacementString: string
        )
    }
}
