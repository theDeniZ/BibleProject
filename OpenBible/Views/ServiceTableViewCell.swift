//
//  ServiceTableViewCell.swift
//  OpenBible
//
//  Created by Denis Dobanda on 15.01.19.
//  Copyright © 2019 Denis Dobanda. All rights reserved.
//

import UIKit

class ServiceTableViewCell: UITableViewCell {

    var name: String? {didSet{updateUI()}}
    var select: Bool = true {didSet{updateUI()}}
    var index: Int = 0
    var delegate: SharingObjectTableCellDelegate? {didSet{updateUI()}}
    var status: SyncStatus = .notStarted
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var switcher: UISwitch!
    @IBOutlet private weak var activity: UIActivityIndicatorView!
    @IBOutlet private weak var statusImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateUI()
    }
    
    private func updateUI() {
        nameLabel?.text = name
        switcher?.isOn = select
        nameLabel?.sizeToFit()
        activity?.stopAnimating()
        switch status {
        case .notStarted:
            switcher?.isHidden = false
            activity?.isHidden = true
            statusImageView?.isHidden = true
        case .started:
            switcher?.isHidden = true
            statusImageView?.isHidden = true
            activity?.isHidden = false
            activity?.startAnimating()
        case .success:
            switcher?.isHidden = true
            activity?.isHidden = true
            statusImageView?.isHidden = false
            statusImageView?.image = UIImage(named: "done")
        case .failure:
            switcher?.isHidden = true
            activity?.isHidden = true
            statusImageView?.isHidden = false
            statusImageView?.image = UIImage(named: "fail")
        }
    }
    
    @IBAction func switched(_ sender: UISwitch) {
        delegate?.sharingTableCellWasSelected(sender.isOn, at: index)
    }
    

}
