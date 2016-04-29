//
//  LivePhoto.swift
//  PodBuildErrorExample
//
//  Created by Watkins, Richmond on 4/29/16.
//  Copyright © 2016 Test. All rights reserved.
//

import Photos

public struct AMALivePhotoImageRef {
    private var _asset : PHAsset
    public var asset : PHAsset { return _asset }
    
    init(phasset : PHAsset) {
        _asset = phasset
    }
    
    public func getSize(localOnly localOnly : Bool) -> Int {
  
        return 0
    }
    
    private func getLivePhotoSize(localOnly localOnly : Bool) -> Int? {
        if #available(iOSApplicationExtension 9.1, *) {
            var retval: Int = 0
            let (photoData, videoData, _) = getLivePhotoData(localOnly: localOnly)
            
            if let photoData = photoData {
                retval += photoData.length
            }
            
            if let videoData = videoData {
                retval += videoData.length
            }
            
            return retval
        } else {
            let opts = PHImageRequestOptions()
            opts.synchronous = true
            opts.networkAccessAllowed = !localOnly
            
            var retval : NSData? = nil
            
            PHImageManager.defaultManager().requestImageDataForAsset(asset, options: opts, resultHandler: { (data : NSData?, dataUTI : String?, imageOrientation : UIImageOrientation, infoDict : [NSObject : AnyObject]?) in
                retval = data
            })
            
            return retval?.length
        }
    }
    
    @available(iOSApplicationExtension 9.1, *)
    public func getLivePhotoData(localOnly localOnly : Bool) -> (photoData: NSData?, videoData: NSData?, error: NSError?) {
        var retval: (photoData: NSData?, videoData: NSData?, error: NSError?)
        
        if let photo = getLivePhotoSynchronously(localOnly: localOnly) {
            
            let resources = PHAssetResource.assetResourcesForLivePhoto(photo)
            
            let opts = PHAssetResourceRequestOptions()
            opts.networkAccessAllowed = !localOnly
            
            let stop = {
            }
            
            var i = 0
            for resource in resources {
                if resource.type == .Photo || resource.type == .PairedVideo {
                    PHAssetResourceManager.defaultManager().requestDataForAssetResource(resource, options: opts, dataReceivedHandler: { data in
                        
                        if resource.type == .Photo {
                            retval.photoData = data
                        } else if resource.type == .PairedVideo {
                            retval.videoData = data
                        }
                        
                        i += 1
                        
                        if i == resources.count {
                            stop()
                        }
                        }, completionHandler: { error in
                            if let error = error {
                                retval.error = error
                                stop()
                            }
                    })
                } else {
                    stop()
                }
            }
        }
        
        return retval
    }
    
    @available(iOSApplicationExtension 9.1, *)
    public func getLivePhotoSynchronously(localOnly localOnly: Bool) -> PHLivePhoto? {
        
        var retLivePhoto: PHLivePhoto?
        
        getLivePhotoAsynchronously(localOnly: localOnly) { (livePhoto) in
            retLivePhoto = livePhoto
        }
        
        return retLivePhoto
    }
    
    @available(iOSApplicationExtension 9.1, *)
    public func getLivePhotoAsynchronously(localOnly localOnly: Bool, completion:(livePhoto: PHLivePhoto?) -> Void) {
        
        var shouldReturn: Bool = true
        let liveOpts = PHLivePhotoRequestOptions()
        liveOpts.networkAccessAllowed = !localOnly
        /*
         We would like to grab HighQuality but right now
         setting this option is freezing execution.
         We believe this is an Apple bug
         
         liveOpts.deliveryMode = .HighQualityFormat
         */
        
        PHImageManager.defaultManager().requestLivePhotoForAsset(asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .Default, options: liveOpts) { (photo, infoDict) in
            
            if !shouldReturn {
                return
            }
            
            // Prevents multiple callbacks. This can happen since we
            // are unable to change the delivery mode as mentioned above
            if shouldReturn {
                completion(livePhoto: photo)
                shouldReturn = false
            }
        }
    }
}