//
//  TrimmerThumb.swift
//  VideoTrimmer
//
//  Created by Burak Akyalçın on 20/10/2022.
//

import UIKit

final class TrimmerThumb: UIView {
    // MARK: Layout constants
    let chevronWidth: CGFloat = 16
    let edgeHeight: CGFloat = 4
    
    private let chevronHorizontalInset: CGFloat = 2
    private let chevronVerticalInset: CGFloat = 8
    
    // MARK: UIControl items
    let leadingGrabber: UIControl = {
        let control = UIControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    let trailingGrabber: UIControl = {
        let control = UIControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    // MARK: Chevron UIImageViews
    private let leadingChevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.compact.left"))
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .white
        imageView.tintAdjustmentMode = .normal
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let trailingChevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.compact.right"))
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .white
        imageView.tintAdjustmentMode = .normal
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: Trimmer views
    private lazy var leadingView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemMint
        view.layer.cornerRadius = 6
        view.layer.cornerCurve = .continuous
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(leadingChevronImageView)
        return view
    }()
    
    private lazy var trailingView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemMint
        view.layer.cornerRadius = 6
        view.layer.cornerCurve = .continuous
        view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trailingChevronImageView)
        return view
    }()
    
    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemMint
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemMint
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var wrapperView: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 2
        view.layer.shadowOpacity = 0.25
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(leadingView)
        view.addSubview(trailingView)
        view.addSubview(topView)
        view.addSubview(bottomView)
        view.addSubview(leadingGrabber)
        view.addSubview(trailingGrabber)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addComponents()
        layoutComponents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addComponents() {
        addSubview(wrapperView)
    }
    
    private func layoutComponents() {
        NSLayoutConstraint.activate([
            wrapperView.leadingAnchor.constraint(equalTo: leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: trailingAnchor),
            wrapperView.topAnchor.constraint(equalTo: topAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: bottomAnchor),
            leadingView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
            leadingView.topAnchor.constraint(equalTo: wrapperView.topAnchor),
            leadingView.bottomAnchor.constraint(equalTo: bottomAnchor),
            leadingView.widthAnchor.constraint(equalToConstant: chevronWidth),
            leadingChevronImageView.leadingAnchor.constraint(equalTo: leadingView.leadingAnchor, constant: chevronHorizontalInset),
            leadingChevronImageView.trailingAnchor.constraint(equalTo: leadingView.trailingAnchor, constant: -chevronHorizontalInset),
            leadingChevronImageView.topAnchor.constraint(equalTo: leadingView.topAnchor, constant: chevronVerticalInset),
            leadingChevronImageView.bottomAnchor.constraint(equalTo: leadingView.bottomAnchor, constant: -chevronVerticalInset),
            trailingView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor),
            trailingView.topAnchor.constraint(equalTo: wrapperView.topAnchor),
            trailingView.bottomAnchor.constraint(equalTo: bottomAnchor),
            trailingView.widthAnchor.constraint(equalToConstant: chevronWidth),
            trailingChevronImageView.leadingAnchor.constraint(equalTo: trailingView.leadingAnchor, constant: chevronHorizontalInset),
            trailingChevronImageView.trailingAnchor.constraint(equalTo: trailingView.trailingAnchor, constant: -chevronHorizontalInset),
            trailingChevronImageView.topAnchor.constraint(equalTo: trailingView.topAnchor, constant: chevronVerticalInset),
            trailingChevronImageView.bottomAnchor.constraint(equalTo: trailingView.bottomAnchor, constant: -chevronVerticalInset),
            topView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: chevronWidth),
            topView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -chevronWidth),
            topView.topAnchor.constraint(equalTo: wrapperView.topAnchor),
            topView.bottomAnchor.constraint(equalTo: wrapperView.topAnchor, constant: edgeHeight),
            bottomView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: chevronWidth),
            bottomView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -chevronWidth),
            bottomView.topAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -edgeHeight),
            bottomView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor),
            leadingGrabber.leadingAnchor.constraint(equalTo: leadingView.leadingAnchor),
            leadingGrabber.widthAnchor.constraint(equalToConstant: chevronWidth),
            leadingGrabber.topAnchor.constraint(equalTo: leadingView.topAnchor),
            leadingGrabber.bottomAnchor.constraint(equalTo: leadingView.bottomAnchor),
            trailingGrabber.widthAnchor.constraint(equalToConstant: chevronWidth),
            trailingGrabber.trailingAnchor.constraint(equalTo: trailingView.trailingAnchor),
            trailingGrabber.topAnchor.constraint(equalTo: trailingView.topAnchor),
            trailingGrabber.bottomAnchor.constraint(equalTo: trailingView.bottomAnchor)
        ])
    }
}

