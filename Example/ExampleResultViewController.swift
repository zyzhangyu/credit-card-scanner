//
//  ExampleResultViewController.swift
//  Example
//
//  Created by miyasaka on 2020/07/30.
//

import CreditCardScanner
import UIKit

class ExampleResultViewController: UIViewController {
    @IBOutlet var resultLabel: UILabel!

    @IBAction func startButton(_ sender: UIButton) {
//        You can change only neccessary parameters.
//        let vc = CreditCardScannerViewController(delegate: self)
//        vc.titleLabelText = "カードを追加"
//        vc.subtitleLabelText = "枠線にカードを合わせてください"
//        vc.cancelButtonTitleText = "キャンセル"
//        vc.cancelButtonTitleTextColor = .orange
//        vc.labelTextColor = .black
//        vc.cameraViewCreditCardFrameStrokeColor = .gray
//        vc.cameraViewMaskLayerColor = .white
//        vc.cameraViewMaskAlpha = 0.7
//        vc.textBackgroundColor = .white

        let vc = CreditCardScannerViewController(delegate: self)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ExampleResultViewController: CreditCardScannerViewControllerDelegate {
    
    /// 隐藏掉 摄像头界面
    func creditCardScannerViewControllerDidCancel(_ viewController: CreditCardScannerViewController) {
        viewController.dismiss(animated: true, completion: nil)
        print("cancel")
    }
 
    /// 如果失败  也隐藏
    func creditCardScannerViewController(_ viewController: CreditCardScannerViewController, didErrorWith error: CreditCardScannerError) {
        print(error.errorDescription ?? "")
        resultLabel.text = error.errorDescription
        viewController.dismiss(animated: true, completion: nil)
    }

    ///信用卡扫描
    func creditCardScannerViewController(_ viewController: CreditCardScannerViewController, didFinishWith card: CreditCard) {
        viewController.dismiss(animated: true, completion: nil)
        
        ///数据
//        var dateComponents = card.expireDate
//        dateComponents?.calendar = Calendar.current
//        let dateFormater = DateFormatter()
//        dateFormater.dateStyle = .short
//        let date = dateComponents?.date.flatMap(dateFormater.string)
        
        
        print("最终返回的card",card)

        let text = [card.cardName, card.cardNation, card.cardAddress, card.cardNumber]
            .compactMap { $0 }
            .joined(separator: "\n")
        resultLabel.text = text
        print("\(card)")
    }
}
