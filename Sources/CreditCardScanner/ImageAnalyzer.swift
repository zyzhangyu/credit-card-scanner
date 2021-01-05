//
//  ImageAnalyzer.swift
//
//
//  Created by miyasaka on 2020/07/30.
//

import Foundation
import Reg
#if canImport(Vision)
import Vision

protocol ImageAnalyzerProtocol: AnyObject {
    /// 解析完成的时候
    func didFinishAnalyzation(with result: Result<CreditCard, CreditCardScannerError>)
}


///定义了一个类
@available(iOS 13, *)
final class ImageAnalyzer {
    enum Candidate: Hashable {
        case number(String), name(String), cardName(String),  cardNation(String), cardAddress(String),cardNumber(String)
        case expireDate(DateComponents)
    }

    typealias PredictedCount = Int

    private var selectedCard = CreditCard()
    private var cacheCard = CreditCardInfo(number: [], name: [], expireDate: [], cardName: [], cardNation: [], cardAddress: [], cardNumber: [])
    
    private var predictedCardInfo: [Candidate: PredictedCount] = [:]

    private weak var delegate: ImageAnalyzerProtocol?
    init(delegate: ImageAnalyzerProtocol) {
        self.delegate = delegate
    }

    // MARK: - Vision-related

    public lazy var request = VNRecognizeTextRequest(completionHandler: requestHandler)

    func analyze(image: CGImage) {
        let requestHandler = VNImageRequestHandler(
            cgImage: image,
            orientation: .up,
            options: [:]
        )

        do {
            request.recognitionLevel = .accurate;
            request.recognitionLanguages = ["zh-CN"]
            request.usesLanguageCorrection = true
            try requestHandler.perform([request])
        } catch {
            let e = CreditCardScannerError(kind: .photoProcessing, underlyingError: error)
            delegate?.didFinishAnalyzation(with: .failure(e))
            delegate = nil
        }
    }

    lazy var requestHandler: ((VNRequest, Error?) -> Void)? = { [weak self] request, _ in
        
        
        
        guard let strongSelf = self else { return }

//        print("进入图片解析部分");
//        let creditCardNumber: Regex = #"(?:\d[ -]*?){13,16}"#
//        let month: Regex = #"(\d{2})\/\d{2}"#
//        let year: Regex = #"\d{2}\/(\d{2})"#
//        let wordsToSkip = ["mastercard", "jcb", "visa", "express", "bank", "card", "platinum", "reward"]
//        // These may be contained in the date strings, so ignore them only for names
//        let invalidNames = ["expiration", "valid", "since", "from", "until", "month", "year"]
//        let name: Regex = #"([A-z]{2,}\h([A-z.]+\h)?[A-z]{2,})"#
        
        guard let results = request.results as? [VNRecognizedTextObservation] else { return }

        var creditCard = CreditCard(number: nil, name: nil, expireDate: nil, cardName: nil, cardNation: nil, cardAddress: nil, cardNumber: nil)

        let maxCandidates = 1
        for result in results {
            guard
                let candidate = result.topCandidates(maxCandidates).first,
                candidate.confidence > 0.1
            else { continue }

            let string = candidate.string
            
            print("字符串是", string)
            ///信用卡部分
//            let containsWordToSkip = wordsToSkip.contains { string.lowercased().contains($0) }
//            if containsWordToSkip { continue }

//            if let cardNumber = creditCardNumber.firstMatch(in: string)?
//                .replacingOccurrences(of: " ", with: "")
//                .replacingOccurrences(of: "-", with: "") {
//                creditCard.number = cardNumber
//
//                // the first capture is the entire regex match, so using the last
//            } else if let month = month.captures(in: string).last.flatMap(Int.init),
//                // Appending 20 to year is necessary to get correct century
//                let year = year.captures(in: string).last.flatMap({ Int("20" + $0) }) {
//                creditCard.expireDate = DateComponents(year: year, month: month)
//
//            } else if let name = name.firstMatch(in: string) {
//                let containsInvalidName = invalidNames.contains { name.lowercased().contains($0) }
//                if containsInvalidName { continue }
//                creditCard.name = name
//
//            } else {
//                continue
//            }
            
            
            
            ///身份证部分
            if candidate.string.contains("名")
            {
                let cardName = candidate.string.components(separatedBy: "名")[1]
                print("查看身份证姓名", cardName)
                creditCard.cardName = cardName
//                continue
            }  else if candidate.string.contains("族") && (candidate.string.contains("别"))
            {
                let nation = candidate.string.components(separatedBy: "族")[1]
                creditCard.cardNation = nation
//                continue
            } else if (candidate.string.contains("住") && candidate.string.contains("址"))
            {
                let address = candidate.string.components(separatedBy: "址")[1]
                creditCard.cardAddress = address
//                continue
            }else if (creditCard.cardAddress != nil) && (creditCard.cardNumber == nil){
                if (candidate.string.contains("公民") && candidate.string.contains("号码")){
                    let ids = candidate.string.components(separatedBy: "号码")[1]
                    creditCard.cardNumber = ids
                }else {
                    creditCard.cardAddress = creditCard.cardAddress! + candidate.string
                    print("查看地址", creditCard.cardAddress)
                }

         
            }
            else if (candidate.string.contains("公民身份") && candidate.string.contains("号码"))
            {
                let ids = candidate.string.components(separatedBy: "号码")[1]
                creditCard.cardNumber = ids
//                continue
            }else {
                  
                continue
            }
        }
            
        
        /// 验证部分
        // Name
//        if let name = creditCard.name {
//            ///预测卡信息  两次以上 才确定
//            let count = strongSelf.predictedCardInfo[.name(name), default: 0]
//            strongSelf.predictedCardInfo[.name(name)] = count + 1
//            if count > 2 {
//                strongSelf.selectedCard.name = name
//            }
//        }
//        // ExpireDate
//        // 过期时间
//        if let date = creditCard.expireDate {
//            let count = strongSelf.predictedCardInfo[.expireDate(date), default: 0]
//            strongSelf.predictedCardInfo[.expireDate(date)] = count + 1
//            if count > 2 {
//                strongSelf.selectedCard.expireDate = date
//            }
//        }
//
//        // Number
//        if let number = creditCard.number {
//            let count = strongSelf.predictedCardInfo[.number(number), default: 0]
//            strongSelf.predictedCardInfo[.number(number)] = count + 1
//            if count > 2 {
//                strongSelf.selectedCard.number = number
//            }
//        }
        
        
        ///身份证姓名
        if (strongSelf.selectedCard.cardName == nil){
            if let cardName = creditCard.cardName {
                print("这里再看cardName", cardName)
                let count = strongSelf.predictedCardInfo[.cardName(cardName), default: 0]
                strongSelf.predictedCardInfo[.cardName(cardName)] = count + 1
                strongSelf.cacheCard.cardName.append(cardName)
                if count > 3 &&  strongSelf.cacheCard.cardName.contains(cardName) {
                    print("姓名已确认")
                    strongSelf.selectedCard.cardName = cardName
                }else {
                    strongSelf.cacheCard.cardName.append(cardName)
                }
            }
        }

        
        
        ///民族
        if (strongSelf.selectedCard.cardNation == nil) {
            if let cardNation = creditCard.cardNation {
                let count = strongSelf.predictedCardInfo[.cardNation(cardNation), default: 0]
                strongSelf.predictedCardInfo[.cardNation(cardNation)] = count + 1
                if count > 2 {
                    print("民族已确认")
                    strongSelf.selectedCard.cardNation = cardNation
                }
            }
        }

        
        ///身份证地址
        if let cardAddress = creditCard.cardAddress {
            let count = strongSelf.predictedCardInfo[.cardAddress(cardAddress), default: 0]
            strongSelf.predictedCardInfo[.cardAddress(cardAddress)] = count + 1
            if count > 2 {
                print("地址已确认")
                strongSelf.selectedCard.cardAddress = cardAddress
            }
        }
        
        ///身份证号码
        if let cardNumber = creditCard.cardNumber {
            let count = strongSelf.predictedCardInfo[.cardNumber(cardNumber), default: 0]
            strongSelf.predictedCardInfo[.cardNumber(cardNumber)] = count + 1
            if count > 2 {
                print("身份证号码已验证")
                strongSelf.selectedCard.cardNumber = cardNumber
            }
        }
        
        
        
        /// 如果选中卡片的 number != nul     返回成功 然后取消代理
        if strongSelf.selectedCard.cardNumber != nil
            && strongSelf.selectedCard.cardName != nil
            && strongSelf.selectedCard.cardNation != nil
            && strongSelf.selectedCard.cardAddress != nil{
            strongSelf.delegate?.didFinishAnalyzation(with: .success(strongSelf.selectedCard))
            strongSelf.delegate = nil
        }
    }
}
#endif
