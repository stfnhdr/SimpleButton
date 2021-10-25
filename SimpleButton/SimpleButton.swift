//
//  SimpleButton.swift
//  Example
//
//  Created by Andreas Tinoco Lobo on 25.03.15.
//  Copyright (c) 2015 Andreas Tinoco Lobo. All rights reserved.
//

import UIKit

open class SimpleButton: UIButton {
    typealias ControlState = UInt
    
    /// Loading view. UIActivityIndicatorView as default
    open var loadingView: UIView?
    
    /// Default duration of animated state change.
    open var defaultAnimationDuration: TimeInterval = 0.1
    
    /// Represents current button state.
    open override var state: UIControl.State {
        // injects custom button state if necessary
        if isLoading {
            var options = SimpleButtonControlState.loading
            options.insert(super.state)
            return options
        }
        return super.state
    }
    
    /// used to lock any animated state transition for initial setup
    private var lockAnimatedUpdate: Bool = true
    
    /// used to determine the `from` value of any animation
    private var sourceLayer: CALayer {
        return (layer.presentation() ?? layer)
    }
    
    // MARK: State values with initial values
    
    private lazy var backgroundColors: [ControlState: SimpleButtonStateChangeValue<CGColor>] = {
        if let color = self.backgroundColor?.cgColor {
            return [UIControl.State.normal.rawValue: SimpleButtonStateChangeValue(value: color, animated: true, animationDuration: self.defaultAnimationDuration)]
        }
        return [:]
    }()
    
    private lazy var borderColors: [ControlState: SimpleButtonStateChangeValue<CGColor>] = {
        if let color = self.layer.borderColor {
            return [UIControl.State.normal.rawValue: SimpleButtonStateChangeValue(value: color, animated: true, animationDuration: self.defaultAnimationDuration)]
        }
        return [:]
    }()
    
    private lazy var buttonScales: [ControlState: SimpleButtonStateChangeValue<CGFloat>] = {
        [UIControl.State.normal.rawValue: SimpleButtonStateChangeValue(value: 1.0, animated: true, animationDuration: self.defaultAnimationDuration)]
    }()
    
    private lazy var borderWidths: [ControlState: SimpleButtonStateChangeValue<CGFloat>] = {
        [UIControl.State.normal.rawValue: SimpleButtonStateChangeValue(value: self.layer.borderWidth, animated: true, animationDuration: self.defaultAnimationDuration)]
    }()
    
    private lazy var cornerRadii: [ControlState: SimpleButtonStateChangeValue<CGFloat>] = {
        [UIControl.State.normal.rawValue: SimpleButtonStateChangeValue(value: self.layer.cornerRadius, animated: true, animationDuration: self.defaultAnimationDuration)]
    }()
    
    private lazy var shadowColors: [ControlState: SimpleButtonStateChangeValue<CGColor>] = {
        if let color = self.layer.shadowColor {
            return [UIControl.State.normal.rawValue: SimpleButtonStateChangeValue(value: color, animated: true, animationDuration: self.defaultAnimationDuration)]
        }
        return [:]
    }()
    
    private lazy var imageTintColor: [ControlState: SimpleButtonStateChangeValue<UIColor>] = {
        if let color = self.imageView?.tintColor {
            return [UIControl.State.normal.rawValue: SimpleButtonStateChangeValue(value: color, animated: true, animationDuration: self.defaultAnimationDuration)]
        }
        return [:]
    }()
    
    private lazy var shadowOpacities: [ControlState: SimpleButtonStateChangeValue<Float>] = {
        [UIControl.State.normal.rawValue: SimpleButtonStateChangeValue(value: self.layer.shadowOpacity, animated: true, animationDuration: self.defaultAnimationDuration)]
    }()
    
    private lazy var shadowOffsets: [ControlState: SimpleButtonStateChangeValue<CGSize>] = {
        [UIControl.State.normal.rawValue: SimpleButtonStateChangeValue(value: self.layer.shadowOffset, animated: true, animationDuration: self.defaultAnimationDuration)]
    }()
    
    private lazy var shadowRadii: [ControlState: SimpleButtonStateChangeValue<CGFloat>] = {
        [UIControl.State.normal.rawValue: SimpleButtonStateChangeValue(value: self.layer.shadowRadius, animated: true, animationDuration: self.defaultAnimationDuration)]
    }()
    
    // MARK: Overrides
    
    open override var isEnabled: Bool {
        didSet {
            // manually enables / disables user interaction to restore correct state if loading or enabled state are switched separate or together
            if !isEnabled {
                self.isUserInteractionEnabled = false
            }
            else if !state.contains(SimpleButtonControlState.loading), isEnabled {
                self.isUserInteractionEnabled = true
            }
            update()
        }
    }
    
    open override var isHighlighted: Bool {
        didSet {
            update()
        }
    }
    
    open override var isSelected: Bool {
        didSet {
            update()
        }
    }
    
    // MARK: Custom states
    
    /// A Boolean value that determines the SimpleButton´s loading state.
    /// Specify `true` to switch to the loading state.
    /// If set to `true`, SimpleButton shows `loadingView` and hides the default `titleLabel` and `imageView`
    open var isLoading: Bool = false {
        didSet {
            DispatchQueue.main.async {
                if self.isLoading {
                    
                    if self.loadingView == nil {
                        self.setDefaultLoadingView()
                    }
                    self.isUserInteractionEnabled = false
                    self.showLoadingView(animaded: true)
                    
                } else {
                    
                    if !self.state.contains(.disabled) {
                        self.isUserInteractionEnabled = true
                    }
                    self.hideLoadingView(animaded: true)
                    
                }
                
                self.update()
            }
        }
    }
    
    // MARK: Initializer
    
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        lockAnimatedUpdate = true
        configureButtonStyles()
        update()
        lockAnimatedUpdate = false
    }
    
    // MARK: Configuration
    
    /**
     To define various styles for specific button states, override this function and set attributes for specific states (e.g. setBackgroundColor(UIColor.blueColor(), for: .Highlighted, animated: true))
     */
    open func configureButtonStyles() {}
    
    // MARK: Setter for state attributes
    
    /**
     Sets the scale for a specific `UIControlState`
     
     - parameter scale:    scale of button
     - parameter state:    determines at which state that scale applies
     - parameter animated: determines if that change in scale should animate. Default is `true`
     - parameter animationDuration: set this value if you need a specific animation duration for this specific state change. If this is nil, the animation duration is taken from `defaultAnimationDuration`
     */
    open func setScale(_ scale: CGFloat, for state: UIControl.State = .normal, animated: Bool = true, animationDuration: TimeInterval? = nil) {
        buttonScales[state.rawValue] = SimpleButtonStateChangeValue(value: scale, animated: animated, animationDuration: animationDuration ?? defaultAnimationDuration)
        updateScale()
    }
    
    /**
     Sets the background color for a specific `UIControlState`
     
     - parameter color:    background color of button
     - parameter state:    determines at which state that background color applies
     - parameter animated: determines if that change in background color should animate. Default is `true`
     - parameter animationDuration: set this value if you need a specific animation duration for this specific state change. If this is nil, the animation duration is taken from `defaultAnimationDuration`
     */
    open func setBackgroundColor(_ color: UIColor, for state: UIControl.State = .normal, animated: Bool = true, animationDuration: TimeInterval? = nil) {
        backgroundColors[state.rawValue] = SimpleButtonStateChangeValue(value: color.cgColor, animated: animated, animationDuration: animationDuration ?? defaultAnimationDuration)
        updateBackgroundColor()
    }
    
    /**
     Sets the border width for a specific `UIControlState`
     
     - parameter width:    border width of button
     - parameter state:    determines at which state that border width applies
     - parameter animated: determines if that change in border width should animate. Default is `true`
     - parameter animationDuration: set this value if you need a specific animation duration for this specific state change. If this is nil, the animation duration is taken from `defaultAnimationDuration`
     */
    open func setBorderWidth(_ width: CGFloat, for state: UIControl.State = .normal, animated: Bool = true, animationDuration: TimeInterval? = nil) {
        borderWidths[state.rawValue] = SimpleButtonStateChangeValue(value: width, animated: animated, animationDuration: animationDuration ?? defaultAnimationDuration)
        updateBorderWidth()
    }
    
    /**
     Sets the border color for a specific `UIControlState`
     
     - parameter color:    border color of button
     - parameter state:    determines at which state that border color applies
     - parameter animated: determines if that change in border color should animate. Default is `true`
     - parameter animationDuration: set this value if you need a specific animation duration for this specific state change. If this is nil, the animation duration is taken from `defaultAnimationDuration`
     */
    open func setBorderColor(_ color: UIColor, for state: UIControl.State = .normal, animated: Bool = true, animationDuration: TimeInterval? = nil) {
        borderColors[state.rawValue] = SimpleButtonStateChangeValue(value: color.cgColor, animated: animated, animationDuration: animationDuration ?? defaultAnimationDuration)
        updateBorderColor()
    }
    
    /**
     Sets the corner radius for a specific `UIControlState`
     
     - parameter radius:   corner radius of button
     - parameter state:    determines at which state that corner radius applies
     - parameter animated: determines if that change in radius of the corners should animate. Default is `true`
     - parameter animationDuration: set this value if you need a specific animation duration for this specific state change. If this is nil, the animation duration is taken from `defaultAnimationDuration`
     */
    open func setCornerRadius(_ radius: CGFloat, for state: UIControl.State = .normal, animated: Bool = true, animationDuration: TimeInterval? = nil) {
        cornerRadii[state.rawValue] = SimpleButtonStateChangeValue(value: radius, animated: animated, animationDuration: animationDuration ?? defaultAnimationDuration)
        updateCornerRadius()
    }
    
    /**
     Sets the shadow color for a specific `UIControlState`
     
     - parameter color:    shadow color of button
     - parameter state:    determines at which state that shadow color applies
     - parameter animated: determines if that change in shadow color should animate. Default is `true`
     - parameter animationDuration: set this value if you need a specific animation duration for this specific state change. If this is nil, the animation duration is taken from `defaultAnimationDuration`
     */
    open func setShadowColor(_ color: UIColor, for state: UIControl.State = .normal, animated: Bool = true, animationDuration: TimeInterval? = nil) {
        shadowColors[state.rawValue] = SimpleButtonStateChangeValue(value: color.cgColor, animated: animated, animationDuration: animationDuration ?? defaultAnimationDuration)
        updateShadowColor()
    }
    
    /**
     Sets the shadow opacity for a specific `UIControlState`
     
     - parameter opacity:  shadow opacity of button
     - parameter state:    determines at which state that shadow opacity applies
     - parameter animated: determines if that change in shadow opacity should animate. Default is `true`
     - parameter animationDuration: set this value if you need a specific animation duration for this specific state change. If this is nil, the animation duration is taken from `defaultAnimationDuration`
     */
    open func setShadowOpacity(_ opacity: Float, for state: UIControl.State = .normal, animated: Bool = true, animationDuration: TimeInterval? = nil) {
        shadowOpacities[state.rawValue] = SimpleButtonStateChangeValue(value: opacity, animated: animated, animationDuration: animationDuration ?? defaultAnimationDuration)
        updateShadowOpacity()
    }
    
    /**
     Sets the shadow radius for a specific `UIControlState`
     
     - parameter radius:   shadow radius of button
     - parameter state:    determines at which state that shadow radius applies
     - parameter animated: determines if that change in shadow radius should animate. Default is `true`
     - parameter animationDuration: set this value if you need a specific animation duration for this specific state change. If this is nil, the animation duration is taken from `defaultAnimationDuration`
     */
    open func setShadowRadius(_ radius: CGFloat, for state: UIControl.State = .normal, animated: Bool = true, animationDuration: TimeInterval? = nil) {
        shadowRadii[state.rawValue] = SimpleButtonStateChangeValue(value: radius, animated: animated, animationDuration: animationDuration ?? defaultAnimationDuration)
        updateShadowRadius()
    }
    
    /**
     Sets the shadow offset for a specific `UIControlState`
     
     - parameter offset:   shadow offset of button
     - parameter state:    determines at which state that shadow offset applies
     - parameter animated: determines if that change in shadow offset should animate. Default is `true`
     - parameter animationDuration: set this value if you need a specific animation duration for this specific state change. If this is nil, the animation duration is taken from `defaultAnimationDuration`
     */
    open func setShadowOffset(_ offset: CGSize, for state: UIControl.State = .normal, animated: Bool = true, animationDuration: TimeInterval? = nil) {
        shadowOffsets[state.rawValue] = SimpleButtonStateChangeValue(value: offset, animated: animated, animationDuration: animationDuration ?? defaultAnimationDuration)
        updateShadowOffset()
    }
    
    /**
     Sets the image tint color for a specific `UIControlState`
     
     - parameter color:    image color of button
     - parameter state:    determines at which state that border color applies
     - parameter animated: determines if that change in border color should animate. Default is `true`
     - parameter animationDuration: set this value if you need a specific animation duration for this specific state change. If this is nil, the animation duration is taken from `defaultAnimationDuration`
     */
    open func setImageColor(_ color: UIColor, for state: UIControl.State = .normal, animated: Bool = true, animationDuration: TimeInterval? = nil) {
        imageTintColor[state.rawValue] = SimpleButtonStateChangeValue(value: color, animated: animated, animationDuration: animationDuration ?? defaultAnimationDuration)
        updateImageTintColor()
    }
    
    /**
     Sets the spacing between `titleLabel` and `imageView`
     
     - parameter spacing: spacing between `titleLabel` and `imageView`
     */
    open func setTitleImageSpacing(_ spacing: CGFloat) {
        imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing / 2)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing / 2, bottom: 0, right: 0)
    }
    
    // MARK: Attribute update helper
    
    /**
     Updates all attributes if necessary. Each update function determines by itself if an update of any attribute is necessary. It also determines if that update should animate.
     
     - parameter lockAnimatedUpdate: set this to true to update without animation, even it´s defined in `SimpleButtonStateChange`. Used to set initial button attributes
     */
    private func update() {
        updateBackgroundColor()
        updateBorderColor()
        updateBorderWidth()
        updateCornerRadius()
        updateScale()
        updateShadowColor()
        updateShadowOffset()
        updateShadowOpacity()
        updateShadowRadius()
        updateImageTintColor()
    }
    
    private func updateCornerRadius() {
        if let stateChange = cornerRadii[state.rawValue] ?? cornerRadii[UIControl.State.normal.rawValue], stateChange.value != layer.cornerRadius {
            if stateChange.animated, !lockAnimatedUpdate {
                animate(layer: layer, from: sourceLayer.cornerRadius as AnyObject?, to: stateChange.value as AnyObject, forKey: "cornerRadius", duration: stateChange.animationDuration)
            }
            layer.cornerRadius = stateChange.value
        }
    }
    
    private func updateImageTintColor() {
        if let stateChange = imageTintColor[state.rawValue] ?? imageTintColor[UIControl.State.normal.rawValue], stateChange.value != imageView?.tintColor {
            if stateChange.animated {
                UIView.animate(withDuration: stateChange.animationDuration, animations: { [weak self] in
                    self?.imageView?.tintColor = stateChange.value
                })
            } else {
                imageView?.tintColor = stateChange.value
            }
        }
    }
    
    private func updateScale() {
        if let stateChange = buttonScales[state.rawValue] ?? buttonScales[UIControl.State.normal.rawValue], transform.a != stateChange.value, transform.b != stateChange.value {
            let animations: (() -> Void) = { [weak self] in
                self?.transform = CGAffineTransform(scaleX: stateChange.value, y: stateChange.value)
            }
            stateChange.animated && !lockAnimatedUpdate ? UIView.animate(withDuration: stateChange.animationDuration, animations: animations) : animations()
        }
    }
    
    private func updateBackgroundColor() {
        if let stateChange = backgroundColors[state.rawValue] ?? backgroundColors[UIControl.State.normal.rawValue], layer.backgroundColor == nil || UIColor(cgColor: layer.backgroundColor!) != UIColor(cgColor: stateChange.value) {
            if stateChange.animated, !lockAnimatedUpdate {
                animate(layer: layer, from: sourceLayer.backgroundColor, to: stateChange.value, forKey: "backgroundColor", duration: stateChange.animationDuration)
            }
            layer.backgroundColor = stateChange.value
        }
    }
    
    private func updateBorderColor() {
        if let stateChange = borderColors[state.rawValue] ?? borderColors[UIControl.State.normal.rawValue], layer.borderColor == nil || UIColor(cgColor: layer.borderColor!) != UIColor(cgColor: stateChange.value) {
            if stateChange.animated, !lockAnimatedUpdate {
                animate(layer: layer, from: sourceLayer.borderColor, to: stateChange.value, forKey: "borderColor", duration: stateChange.animationDuration)
            }
            layer.borderColor = stateChange.value
        }
    }
    
    private func updateBorderWidth() {
        if let stateChange = borderWidths[state.rawValue] ?? borderWidths[UIControl.State.normal.rawValue], stateChange.value != layer.borderWidth {
            if stateChange.animated, !lockAnimatedUpdate {
                animate(layer: layer, from: sourceLayer.borderWidth as AnyObject?, to: stateChange.value as AnyObject, forKey: "borderWidth", duration: stateChange.animationDuration)
            }
            layer.borderWidth = stateChange.value
        }
    }
    
    private func updateShadowOffset() {
        if let stateChange = shadowOffsets[state.rawValue] ?? shadowOffsets[UIControl.State.normal.rawValue], stateChange.value != layer.shadowOffset {
            if stateChange.animated, !lockAnimatedUpdate {
                animate(layer: layer, from: NSValue(cgSize: sourceLayer.shadowOffset), to: NSValue(cgSize: stateChange.value), forKey: "shadowOffset", duration: stateChange.animationDuration)
            }
            layer.shadowOffset = stateChange.value
        }
    }
    
    private func updateShadowColor() {
        if let stateChange = shadowColors[state.rawValue] ?? shadowColors[UIControl.State.normal.rawValue], layer.shadowColor == nil || UIColor(cgColor: layer.shadowColor!) != UIColor(cgColor: stateChange.value) {
            if stateChange.animated, !lockAnimatedUpdate {
                animate(layer: layer, from: sourceLayer.shadowColor, to: stateChange.value, forKey: "shadowColor", duration: stateChange.animationDuration)
            }
            layer.shadowColor = stateChange.value
        }
    }
    
    private func updateShadowRadius() {
        if let stateChange = shadowRadii[state.rawValue] ?? shadowRadii[UIControl.State.normal.rawValue], stateChange.value != layer.shadowRadius {
            if stateChange.animated, !lockAnimatedUpdate {
                animate(layer: layer, from: sourceLayer.shadowRadius as AnyObject?, to: stateChange.value as AnyObject, forKey: "shadowRadius", duration: stateChange.animationDuration)
            }
            layer.shadowRadius = stateChange.value
        }
    }
    
    private func updateShadowOpacity() {
        if let stateChange = shadowOpacities[state.rawValue] ?? shadowOpacities[UIControl.State.normal.rawValue], stateChange.value != layer.shadowOpacity {
            if stateChange.animated, !lockAnimatedUpdate {
                animate(layer: layer, from: sourceLayer.shadowOpacity as AnyObject?, to: stateChange.value as AnyObject, forKey: "shadowOpacity", duration: stateChange.animationDuration)
            }
            layer.shadowOpacity = stateChange.value
        }
    }
    
    // MARK: Animation helper
    
    private func animate(layer: CALayer, from: AnyObject?, to: AnyObject, forKey key: String, duration: TimeInterval) {
        let animation = CABasicAnimation()
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        layer.add(animation, forKey: key)
    }
    
    // MARK: Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        loadingView?.center = CGPoint(x: bounds.size.width / 2,
                                      y: bounds.size.height / 2)
    }
    
    // MARK: - LoadingView
    
    private func setDefaultLoadingView() {
        let activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = false
        activityIndicator.alpha = 0
        loadingView = activityIndicator
    }
    
    private func addLoadingViewAsSubView() {
        guard let loadingView = loadingView else { return }
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            trailingAnchor.constraint(equalTo: loadingView.trailingAnchor, constant: contentEdgeInsets.right),
            loadingView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentEdgeInsets.left),
            loadingView.topAnchor.constraint(equalTo: topAnchor, constant: contentEdgeInsets.top),
            bottomAnchor.constraint(equalTo: loadingView.bottomAnchor, constant: contentEdgeInsets.bottom)
        ])
        layoutIfNeeded()
    }
    
    private func removeLoadingViewAsSubView() {
        loadingView?.removeFromSuperview()
        layoutIfNeeded()
    }
    
    private func showLoadingView(animaded: Bool) {
        let animation = { [weak self] in
            self?.loadingView?.alpha = 1
            self?.titleLabel?.layer.opacity = 0
            self?.imageView?.alpha = 0
        }
        
        if loadingView?.superview == nil {
            addLoadingViewAsSubView()
            loadingView?.alpha = 0
        }
        
        if animaded {
            loadingView?.alpha = 0
            UIView.animate(withDuration: defaultAnimationDuration, animations: animation)
        } else {
            animation()
        }
    }
    
    private func hideLoadingView(animaded: Bool) {
        let animation = { [weak self] in
            self?.loadingView?.alpha = 0
            self?.titleLabel?.layer.opacity = 2
            self?.imageView?.alpha = 1
        }
        let completion: (Bool) -> Void = { [weak self] _ in
            self?.removeLoadingViewAsSubView()
        }
        
        if animaded {
            UIView.animate(withDuration: defaultAnimationDuration, animations: animation, completion: completion)
        } else {
            animation()
            completion(true)
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        update()
    }
}
