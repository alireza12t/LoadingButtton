import UIKit

@IBDesignable public class LoadingButton: UIButton {
    
    public var originalWidth: CGFloat = UIScreen.main.bounds.width - 32
    private var originalTitle: String?
    private var originalImage = UIImage()
    private var minWidth: CGFloat = 20
    private var widthConstraint: NSLayoutConstraint!
    private var enabledState: Bool? = nil
    
    @IBInspectable public var animationDuration: Double = 1.2
    @IBInspectable public var loadingText: String = "Loading..."
    @IBInspectable public var loaddingBackgroundColor: UIColor = .systemGray
    
    public var isAnimating: Bool = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                if self?.isAnimating ?? false {
                    self?.startAnimating()
                } else {
                    self?.stopAnimating()
                }
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public func setupUI() {
        layer.cornerRadius = self.cornerRadius
        layer.shadowOpacity = Float(shadowOpacity)
        layer.shadowOffset.height = shadowOffsetY
        layer.shadowRadius = shadowRadius
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        layer.shadowColor = shadowColor.cgColor
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        loadingText.width(withConstrainedHeight: self.bounds.height, font: self.titleLabel?.font ?? .systemFont(ofSize: 18, weight: .bold)) { [self] (width) in
            minWidth = width + 30
            widthConstraint = widthAnchor.constraint(equalToConstant: originalWidth)
            NSLayoutConstraint.activate([self.widthConstraint])
        }
    }
    
    private func startAnimating() {
        enabledState = isEnabled
        isEnabled = false
        originalTitle = (titleLabel?.text ?? "Button") == "Button" ? title(for: .normal) : titleLabel?.text
        originalImage = imageView?.image ?? UIImage()
        titleLabel?.text = loadingText
        setTitle(loadingText, for: .normal)
        originalBackgroundColor = backgroundColor ?? .blue
        backgroundColor = loaddingBackgroundColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.short()
        }
    }
    
    private func stopAnimating() {
        isEnabled = enabledState ?? false
        titleLabel?.text = originalTitle
        setTitle(originalTitle, for: .normal)
        backgroundColor = originalBackgroundColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.long()
        }
    }
    
    private func short() {
        UIView.animate(withDuration: animationDuration) { [weak self] in
            self?.widthConstraint?.constant = self?.minWidth ?? 0
            self?.layoutIfNeeded()
        } completion: { [weak self] (_) in
            self?.long()
        }
    }
    
    private func long() {
        UIView.animate(withDuration: animationDuration) { [weak self] in
            self?.widthConstraint.constant = self?.originalWidth ?? 0
            self?.layoutIfNeeded()
        } completion: { [weak self] (_) in
            guard let self = self else {
                return
            }
            if self.isAnimating {
                self.short()
            }
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        shrink()
        lightVibrate()
    }
    
    func lightVibrate() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        restore()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        restore()
    }
    
    func shrink() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self?.layoutIfNeeded()
        }
    }
    
    func restore() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 1, y: 1)
            self?.layoutIfNeeded()
        }
    }
    
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable public var originalBackgroundColor: UIColor = .blue {
        didSet {
            self.backgroundColor = originalBackgroundColor
        }
    }
    
    @IBInspectable public var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable public var shadowColor: UIColor = UIColor.clear {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable public var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable public var shadowOpacity: CGFloat = 0 {
        didSet {
            layer.shadowOpacity = Float(shadowOpacity)
        }
    }
    
    @IBInspectable public var shadowOffsetY: CGFloat = 0 {
        didSet {
            layer.shadowOffset.height = shadowOffsetY
        }
    }
}

extension LoadingButton {
    override open var isEnabled: Bool {
        didSet {
            DispatchQueue.main.async {
                if self.isEnabled {
                    self.alpha = 1.0
                }
                else {
                    self.alpha = 0.6
                }
            }
        }
    }
}

extension DispatchQueue {
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
}

extension String {
    func width(withConstrainedHeight height: CGFloat, font: UIFont, finished: @escaping (CGFloat)->()) {
        var boundingBox:CGRect = .zero
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        DispatchQueue.background(delay: 0, background: {
            boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        }, completion: {
            finished(ceil(boundingBox.width))
        })
    }
}
