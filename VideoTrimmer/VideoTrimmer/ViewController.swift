//
//  ViewController.swift
//  VideoTrimmer
//
//  Created by Burak Akyalçın on 20/10/2022.
//

import UIKit
import AVKit
import Photos

class ViewController: UIViewController {
    private let playerController: AVPlayerViewController = {
        let playerController = AVPlayerViewController()
        playerController.player = AVPlayer()
        playerController.view.translatesAutoresizingMaskIntoConstraints = false
        return playerController
    }()
    
    private lazy var trimmer: Trimmer = {
        var trimmer = Trimmer()
        trimmer.minimumDuration = CMTime(seconds: 1, preferredTimescale: 600)
        trimmer.addTarget(self, action: #selector(didBeginTrimming(_:)), for: Trimmer.didBeginTrimming)
        trimmer.addTarget(self, action: #selector(didEndTrimming(_:)), for: Trimmer.didEndTrimming)
        trimmer.addTarget(self, action: #selector(selectedRangeDidChanged(_:)), for: Trimmer.selectedRangeChanged)
        trimmer.addTarget(self, action: #selector(didBeginScrubbing(_:)), for: Trimmer.didBeginScrubbing)
        trimmer.addTarget(self, action: #selector(didEndScrubbing(_:)), for: Trimmer.didEndScrubbing)
        trimmer.addTarget(self, action: #selector(progressDidChanged(_:)), for: Trimmer.progressChanged)
        trimmer.translatesAutoresizingMaskIntoConstraints = false
        trimmer.asset = asset
        return trimmer
    }()
    
    private lazy var timingStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [leadingTrimLabel, currentTimeLabel, trailingTrimLabel])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let leadingTrimLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textAlignment = .left
        label.textColor = .white
        return label
    }()
    
    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    private let trailingTrimLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textAlignment = .right
        label.textColor = .white
        return label
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitleColor(.systemYellow, for: .normal)
        button.setTitle("Save to device", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapExport), for: .touchUpInside)
        return button
    }()
    
    private var wasPlaying = false
    
    private var player: AVPlayer? { playerController.player }
    
    private let asset = AVURLAsset(
        url: Bundle.main.resourceURL!.appendingPathComponent("SampleVideo.mp4"),
        options: [AVURLAssetPreferPreciseDurationAndTimingKey: true]
    )
    
    // MARK: - Input
    @objc private func didBeginTrimming(_ sender: Trimmer) {
        updateLabels()
        
        wasPlaying = (player?.timeControlStatus != .paused)
        player?.pause()
        
        updatePlayerAsset()
    }
    
    @objc private func didEndTrimming(_ sender: Trimmer) {
        updateLabels()
        
        if wasPlaying == true {
            player?.play()
        }
        
        updatePlayerAsset()
    }
    
    @objc private func selectedRangeDidChanged(_ sender: Trimmer) {
        updateLabels()
    }
    
    @objc private func didBeginScrubbing(_ sender: Trimmer) {
        updateLabels()
        
        wasPlaying = (player?.timeControlStatus != .paused)
        player?.pause()
    }
    
    @objc private func didEndScrubbing(_ sender: Trimmer) {
        updateLabels()
        
        if wasPlaying == true {
            player?.play()
        }
    }
    
    @objc private func progressDidChanged(_ sender: Trimmer) {
        updateLabels()
        
        let time = CMTimeSubtract(trimmer.progress, trimmer.selectedRange.start)
        player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    @objc private func didTapExport() {
        let outputRange = trimmer.trimmingState == .none ? trimmer.selectedRange : asset.fullRange
        let trimmedAsset = asset.trimmedComposition(outputRange)
        export(asset: trimmedAsset)
    }
    
    // MARK: - Private
    private func updateLabels() {
        leadingTrimLabel.text = trimmer.selectedRange.start.displayString
        currentTimeLabel.text = trimmer.progress.displayString
        trailingTrimLabel.text = trimmer.selectedRange.end.displayString
    }
    
    private func updatePlayerAsset() {
        let outputRange = trimmer.trimmingState == .none ? trimmer.selectedRange : asset.fullRange
        let trimmedAsset = asset.trimmedComposition(outputRange)
        if trimmedAsset != player?.currentItem?.asset {
            player?.replaceCurrentItem(with: AVPlayerItem(asset: trimmedAsset))
        }
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        addComponents()
        layoutComponents()
        
        updatePlayerAsset()
        player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 30), queue: .main) { [weak self] time in
            guard let self else {return}
            let finalTime = self.trimmer.trimmingState == .none ? CMTimeAdd(time, self.trimmer.selectedRange.start) : time
            self.trimmer.progress = finalTime
        }
        updateLabels()
    }
    
    private func addComponents() {
        addChild(playerController)
        view.addSubview(playerController.view)
        view.addSubview(trimmer)
        view.addSubview(timingStackView)
        view.addSubview(saveButton)
    }
    
    private func layoutComponents() {
        NSLayoutConstraint.activate([
            playerController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerController.view.bottomAnchor.constraint(equalTo: trimmer.topAnchor, constant: -16),
            trimmer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trimmer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            trimmer.bottomAnchor.constraint(equalTo: timingStackView.bottomAnchor, constant: -32),
            trimmer.heightAnchor.constraint(equalToConstant: 44),
            timingStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            timingStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            timingStackView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -16),
            saveButton.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor),
            saveButton.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func export(asset: AVAsset) {
        let exportPath = NSTemporaryDirectory().appendingFormat("/video.mov")
        let exportURL = URL(fileURLWithPath: exportPath)

        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputURL = exportURL
        exporter?.outputFileType = AVFileType.mp4

        exporter?.exportAsynchronously(completionHandler: {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: exportURL)
            }) { [weak self] saved, error in
                DispatchQueue.main.async {
                    if saved {
                        self?.showSaveToPhotosSuccessAlert()
                    } else {
                        self?.showSaveToPhotosFailureAlert()
                    }
                }
            }
        })
    }
    
    private func showSaveToPhotosSuccessAlert() {
        let alert = UIAlertController(title:"Info", message: "Saved to device.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    private func showSaveToPhotosFailureAlert() {
        let alert = UIAlertController(title: "Error", message: "Failed to save the video.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
}

extension CMTime {
    var displayString: String {
        let offset = TimeInterval(seconds)
        let numberOfNanosecondsFloat = (offset - TimeInterval(Int(offset))) * 1000.0
        let nanoseconds = Int(numberOfNanosecondsFloat)
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return String(format: "%@.%03d", formatter.string(from: offset) ?? "00:00", nanoseconds)
    }
}

extension AVAsset {
    var fullRange: CMTimeRange {
        return CMTimeRange(start: .zero, duration: duration)
    }
    
    func trimmedComposition(_ range: CMTimeRange) -> AVAsset {
        guard CMTimeRangeEqual(fullRange, range) == false else {return self}
        
        let composition = AVMutableComposition()
        try? composition.insertTimeRange(range, of: self, at: .zero)
        
        if let videoTrack = tracks(withMediaType: .video).first {
            composition.tracks.forEach {$0.preferredTransform = videoTrack.preferredTransform}
        }
        return composition
    }
}



