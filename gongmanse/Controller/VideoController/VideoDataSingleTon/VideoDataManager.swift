//
//  VideoDataManager.swift
//  gongmanse
//
//  Created by 김우성 on 2021/06/11.
//

import Foundation
import UIKit.UIImage

class VideoDataManager {
    
    static let shared = VideoDataManager()
    private init() { }
    
    var isFirstPlayVideo: Bool = true
    var currentPlayVideoIndex = 0             // 현재 비디오의 인덱스
    var videoPlayIDLog = [String]()           // 실행된 영상의 ID를 저장하는 array
    var videoPlayURLLog = [NSURL?]()          // 실행된 영상의 URL을 저장하는 array
    var videoPlaySubtitleURLLog = [String]()  // 실행된 영상의 subtitleURL을 저장하는 array
    var videoTeachernameLog = [String]()
    var videoTitleLog = [String]()
    var videoThumbnailImageLog = [UIImage]()
    
    
    /// 제일 최근에 재생된 비디오 ID
    var currentVideoID: String? {
        return videoPlayIDLog.last
    }
    
    // 제일 최근에 재댕쇤 비디오 URL
    var currentVideoURL: NSURL? {
        return videoPlayURLLog.last ?? NSURL()
    }
    
    /// 바로 이전에 재생된 비디오 ID
    var previousVideoID: String? {
        // TODO: 만약 로그가 하나인 경우, 어떻게 처리할지 고민해야한다.
        if videoPlayIDLog.count < 2 {
            return videoPlayIDLog.first
        } else {
            return videoPlayIDLog[videoPlayIDLog.count - 2]
        }
    }
    
    /// 바로 이전에 재생된 비디오 URL
    var previousVideoURL: NSURL? {
        // TODO: 만약 로그가 하나인 경우, 어떻게 처리할지 고민해야한다.
        if videoPlayURLLog.count == 1 {
            return videoPlayURLLog.first ?? NSURL()
        } else if videoPlayURLLog.count == 2 {
            return videoPlayURLLog.first ?? NSURL()
        } else {
            // 2개 이상인 경우,
            return videoPlayURLLog[videoPlayURLLog.endIndex - 1]
        }
    }
    
    /// 바로 이전에 재생된 비디오 타이틀
    var previousVideoTitle: String? {
        // TODO: 만약 로그가 하나인 경우, 어떻게 처리할지 고민해야한다.
        if videoTitleLog.count < 2 {
            return videoTitleLog.first
        } else {
            return videoTitleLog[videoTitleLog.count - 2]
        }
    }
    
    /// 바로 이전에 재생된 비디오 타이틀
    var previousVideoTeachername: String? {
        // TODO: 만약 로그가 하나인 경우, 어떻게 처리할지 고민해야한다.
        if videoTeachernameLog.count < 2 {
            return videoTeachernameLog.first
        } else {
            return videoTeachernameLog[videoTeachernameLog.count - 2]
        }
    }
    
    /// 바로 이전에 재생된 영상의 섬네일 이미지를 리턴한다.
    var previousvideoThumbnailImage: UIImage? {
        if videoThumbnailImageLog.count == 1 {
            return videoThumbnailImageLog.first
        } else if videoThumbnailImageLog.count == 2 {
            return videoThumbnailImageLog.first
        } else {
            return videoThumbnailImageLog[videoThumbnailImageLog.endIndex - 1]
        }
    }
    
    /// 비디오ID를 로그에 추가하는 메소드
    func addVideoIDLog(videoID: String) {
        self.videoPlayIDLog.append(videoID)
    }
    
    /// 비디오URL을 로그에 추가하는 메소드
    func addVideoURLLog(videoURL: NSURL?) {
        self.videoPlayURLLog.append(videoURL)
    }
    
    /// 비디오subtitleURL을 로그에 추가하는 메소드
    func addVideoSubtitleURLLog(videoSubtitleURL: String) {
        self.videoPlaySubtitleURLLog.append(videoSubtitleURL)
    }
    
    /// 비디오 선생님이름을 로그에 추가하는 메소드
    func addVideoTeachername(teachername: String) {
        self.videoTeachernameLog.append(teachername)
    }
    
    /// 비디오 영상제목을 로그에 추가하는 메소드
    func addVideoTitle(videoTitle: String) {
        self.videoTitleLog.append(videoTitle)
    }
    
    /// 썸네일 이미지를 로그에 추가하는 메소드
    func addVideoThumbnailImage(videoImage: UIImage) {
        self.videoThumbnailImageLog.append(videoImage)
    }
}
