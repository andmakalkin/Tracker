import UIKit

enum UserDefaultsKey {
    static let didShowOnboarding = "didShowOnboarding"
}

final class OnboardingViewController: UIPageViewController {

    // MARK: - Child View Controllers
    private let firstViewController = UIViewController()
    private let secondViewController = UIViewController()
    
    // MARK: - UI Elements
    private lazy var pageControl = UIPageControl()
    private lazy var doneButton = UIButton(type: .custom)
    
    // MARK: - Data
    private lazy var pages: [UIViewController] = [
        firstViewController,
        secondViewController
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        setupView()
    }
    
    // MARK: - UI Setup
    private func setupView() {
        setupDoneButton()
        setupFirstViewController()
        setupSecondViewController()
        setupPageControl()
        setupPageViewController()
    }
    
    private func setupDoneButton() {
        doneButton.addTarget(
            self,
            action: #selector(doneButtonDidTap),
            for: .touchUpInside
        )
        
        doneButton.setTitle("Вот это технологии!", for: .normal)
        doneButton.setTitleColor(.ypWhite, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        doneButton.backgroundColor = .ypBlack
        doneButton.layer.cornerRadius = 16
        doneButton.layer.masksToBounds = true
        
        view.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            doneButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            doneButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -50
            ),
            doneButton.heightAnchor.constraint(
                equalToConstant: 60
            ),
        ])
    }
    
    private func setupFirstViewController() {
        setupViewController(
            firstViewController,
            backgroundImage: UIImage(resource: .onboardingBackgroundBlue),
            text: "Отслеживайте только\nто, что хотите"
        )
    }
    
    private func setupSecondViewController() {
        setupViewController(
            secondViewController,
            backgroundImage: UIImage(resource: .onboardingBackgroundRed),
            text: "Даже если это\nне литры воды и йога"
        )
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = .ypBlack.withAlphaComponent(0.3)
        
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(
                equalTo: doneButton.topAnchor,
                constant: -24
            ),
            pageControl.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
        ])
    }
    
    private func setupPageViewController() {
        if let first = pages.first {
            setViewControllers(
                [first],
                direction: .forward,
                animated: true,
                completion: nil
            )
        }
    }
    
    private func setupViewController(
        _ viewController: UIViewController,
        backgroundImage: UIImage,
        text: String
    ) {
        let backgroundImageView = UIImageView()
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFit
        
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        textLabel.numberOfLines = 2
        textLabel.textAlignment = .center
        
        viewController.view.addSubview(backgroundImageView)
        viewController.view.addSubview(textLabel)
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(
                equalTo: viewController.view.topAnchor
            ),
            backgroundImageView.bottomAnchor.constraint(
                equalTo: viewController.view.bottomAnchor
            ),
            backgroundImageView.leadingAnchor.constraint(
                equalTo: viewController.view.leadingAnchor
            ),
            backgroundImageView.trailingAnchor.constraint(
                equalTo: viewController.view.trailingAnchor
            ),
            
            textLabel.leadingAnchor.constraint(
                equalTo: viewController.view.leadingAnchor,
                constant: 16
            ),
            textLabel.trailingAnchor.constraint(
                equalTo: viewController.view.trailingAnchor,
                constant: -16
            ),
            textLabel.bottomAnchor.constraint(
                equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor,
                constant: -270
            ),
        ])
    }
    
    // MARK: - Actions
    @objc
    private func doneButtonDidTap() {
        UserDefaults.standard.set(
            true,
            forKey: UserDefaultsKey.didShowOnboarding
        )
        switchToMainScreen()
    }
    
    // MARK: - Navigation
    private func switchToMainScreen() {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first
        else { return }
        
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return pages.last
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return pages.first
        }
        
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

