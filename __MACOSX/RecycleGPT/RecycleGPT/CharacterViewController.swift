//
//  CharacterViewController.swift
//  Rubbish
//
//  Created by Emin Israfil on 11/15/23.
//  Copyright © 2023 Emin Israfil. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Kingfisher

class CharacterViewController: UIViewController {
    private var imageView: UIImageView!
    private var doneButton: UIButton!
    private var instructionLabel: UILabel!
    private var secondLabel: UILabel!
    private var image: UIImage?  // Property to hold the image
    private var url: URL?

    init(image: UIImage? = nil, url: URL? = nil) {
        self.image = image
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .black
        
        // Setup ImageView with the passed image
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        if let image = self.image {
            imageView.image = image
        } else if let url = self.url {
            // If no image is provided, use Kingfisher to load the image from the URL
            imageView.kf.setImage(with: url)
        }

        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Setup Done Button
        doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        view.addSubview(doneButton)
        doneButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.right.equalToSuperview().inset(20)
        }

        // Setup Instruction Label
        instructionLabel = UILabel()
        instructionLabel.font = Fonts.breakDownCallout // Modify as needed
        instructionLabel.text = "Keep up the great work! 🎉"
        instructionLabel.backgroundColor = .black
        instructionLabel.textAlignment = .center
        instructionLabel.textColor = .white
        instructionLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.addSubview(instructionLabel)
        instructionLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(100)
            make.centerX.equalToSuperview()
        }

        // Setup Second Label
        secondLabel = UILabel()
        secondLabel.font = UIFont.systemFont(ofSize: 16) // Modify as needed
        secondLabel.text = ""
        secondLabel.textAlignment = .center
        secondLabel.textColor = .white
        view.addSubview(secondLabel)
        secondLabel.snp.makeConstraints { make in
            make.top.equalTo(instructionLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
    }

    @objc private func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
}
