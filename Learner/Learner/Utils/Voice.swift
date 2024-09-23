//
//  Voice.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-22.
//

import Foundation

import AVFoundation

class Voice {
    let synthesizer = AVSpeechSynthesizer()
    var utterance : AVSpeechUtterance?
    var lang: String = "en"
    
    init(utterance: AVSpeechUtterance? = nil, lang: String) {
        self.utterance = utterance
        let english = Locale(identifier: lang)
        self.lang = english.identifier
    }
    
    func strToVoice(text:String){
        utterance = AVSpeechUtterance(string: text)
        utterance!.voice = AVSpeechSynthesisVoice(language: lang)
        synthesizer.speak(utterance!)
    }
    
    func sayAgain(){
        if let u = utterance {
            
            if synthesizer.isSpeaking {
                return
            }
            u.rate = 0.1
            synthesizer.speak(u)
        }
    }
}

