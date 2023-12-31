//
//  File.swift
//  
//
//  Created by Ghullam  Abbas on 05/10/2023.
//

import Foundation
import UIKit
import AVFoundation
import YouTubeiOSPlayerHelper
import SmilesUtilities

 @objc public protocol SmilesYoutubeViewDelegate: AnyObject {
     @objc func didTappedClose()
     @objc func didTappedExpand()
}

public class SmilesYoutubePopUpView: UIView, YTNibLoadable {
    @IBOutlet private var containerView: UIView!
    @IBOutlet weak var shadowParentView: UIView!
    @IBOutlet weak var roundedCornerView: UIView!
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var expandBtn: UIButton!
    @objc @IBOutlet weak public var thumbImgView: UIImageView!
    @IBOutlet weak var ytPlayerView: YTPlayerView!
    
    @objc public var ytViewDelegate: SmilesYoutubeViewDelegate?
    @objc var nibName = "SmilesYoutubePopUpView"
    @objc var contentView: UIView?
    
    public  required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
//        self.roundedCornerView.RoundedViewConrner(cornerRadius: 12)
        
        self.shadowParentView.addShadowToSelf(offset: CGSize(width: 2.0, height: 2.0), color: UIColor.lightGray, radius: 4, opacity: 0.8)
        roundedCornerView.RoundedViewConrner(cornerRadius: 12)
    }
    
    public  override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }
    
      @IBAction func onCloseBtnTapped(_ sender: Any) {
        print("close tapped")
        if ytViewDelegate != nil {
            ytViewDelegate?.didTappedClose()
        }
    }
    
      @IBAction func onExpandBtnTapped(_ sender: Any) {
        print("Expand tapped")
        if ytViewDelegate != nil {
            ytViewDelegate?.didTappedExpand()
            expandBtn.isHidden = true
        }
    }
    
    @objc public func playVideo(videoURL: String?) {
        
        self.thumbImgView.isHidden = true
        self.ytPlayerView.isHidden = false
        roundedCornerView.RoundedViewConrner(cornerRadius: 0)

        if let videoUrl = NSURL(string: videoURL.asStringOrEmpty()) {
            
            if videoUrl.absoluteString!.contains("youtube.com") {
                // do something here
                let youtubeId = extractYoutubeId(fromLink: videoURL.asStringOrEmpty())
                ytPlayerView.load(withVideoId: youtubeId, playerVars: ["origin": "http://www.youtube.com","autoplay": 1,"playsinline": 1, "showinfo": 1, "rel" : 0])
                ytPlayerView.delegate = self;
                
            } else {
                let player = AVPlayer(url: videoUrl as URL)
                
                let playerLayer  = AVPlayerLayer(player: player)
                self.layer.addSublayer(playerLayer)
                playerLayer.frame =  self.frame
                
                player.play()
            }
        }
    }
    
    public  func extractYoutubeId(fromLink link: String) -> String {
        let regexString: String = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
        let regExp = try? NSRegularExpression(pattern: regexString, options: .caseInsensitive)
        let array: [Any] = (regExp?.matches(in: link, options: [], range: NSRange(location: 0, length: (link.count ))))!
        if array.count > 0 {
            let result: NSTextCheckingResult? = array.first as? NSTextCheckingResult
            return (link as NSString).substring(with: (result?.range)!)
        }
        
        return ""
    }
}


extension SmilesYoutubePopUpView: YTPlayerViewDelegate {
    public func  playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
    }

}
public protocol YTNibLoadable {
    static var nibName: String { get }
}

public extension YTNibLoadable where Self: UIView {

    static var nibName: String {
        return String(describing: Self.self) // defaults to the name of the class implementing this protocol.
    }

    static var nib: UINib {
        
        let bundle = Bundle.module
        return UINib(nibName: Self.nibName, bundle: bundle)
    }

    func setupFromNib() {
        let bundle = Bundle.module
        let nib: UINib = UINib(nibName: "SmilesYoutubePopUpView", bundle: bundle)
        
//        guard let view = bundle.loadNibNamed("SmilesYoutubePopUpView", owner: self, options: nil)?.first as? SmilesYoutubePopUpView else {
//            fatalError("Error loading \(self) from nib")
//            }
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { fatalError("Error loading \(self) from nib") }
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
}
