//
//  PHSourceManager.m
//  RJPhotoGallery
//
//  Created by Rylan Jin on 9/25/15.
//  Copyright © 2015 Rylan Jin. All rights reserved.
//

#import "PHSourceManager.h"
#import "AlbumObj.h"
#import "ImageDataAPI.h"
#import "PhotoObj.h"

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

@implementation PHSourceManager

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.manager = [[PHImageManager alloc] init];
    }
    return self;
}

- (BOOL)haveAccessToPhotos
{
    return ( [PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusRestricted &&
             [PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusDenied );
}

- (void)getMomentsWithAscending:(BOOL)ascending
                     completion:(void (^)(BOOL ret, id obj))completion
{
    PHFetchOptions *options  = [[PHFetchOptions alloc] init];
    options.sortDescriptors  = @[[NSSortDescriptor sortDescriptorWithKey:@"endDate"
                                                               ascending:ascending]];
    
    PHFetchResult  *momentRes = [PHAssetCollection fetchMomentsWithOptions:options];
    NSMutableArray *momArray  = [[NSMutableArray alloc] init];
    
    for (PHAssetCollection *collection in momentRes)
    {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit   |
                                                                                NSMonthCalendarUnit |
                                                                                NSYearCalendarUnit
                                                                       fromDate:collection.endDate];
        NSUInteger month = [components month];
        NSUInteger year  = [components year];
        NSUInteger day   = [components day];
        
        MomentCollection *moment = [MomentCollection new];
        moment.month = month; moment.year = year; moment.day = day;
        
        PHFetchOptions *option  = [[PHFetchOptions alloc] init];
        option.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeImage];
        
        moment.assetObjs = [PHAsset fetchAssetsInAssetCollection:collection
                                                         options:option];
        if ([moment.assetObjs count]) [momArray addObject:moment];
    }
    
    completion(YES, momArray);
}

- (void)getThumbnailForAssetObj:(id)asset
                       withSize:(CGSize)size
                   deliveryMode:(PHImageRequestOptionsDeliveryMode)deliveryMode
                     completion:(void (^)(BOOL ret, UIImage *image))completion
{
  if (![asset isKindOfClass:[PHAsset class]])
  {
    completion(NO, nil); return;
  }
  PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
  options.resizeMode = PHImageRequestOptionsResizeModeFast;
  options.deliveryMode = deliveryMode;
  PHAsset *a = asset;
  CGFloat w = (a.pixelWidth > a.pixelHeight)?a.pixelHeight:a.pixelWidth;
  if (w > 100)
  {
    w = 100;
  }
  CGRect rect = CGRectMake(0, 0, w, w);
  options.normalizedCropRect = rect;
  options.synchronous = NO;
  CGFloat scale = [UIScreen mainScreen].scale;
  size  = CGSizeMake(size.width * scale, size.height * scale);
  [self.manager requestImageForAsset:asset
                          targetSize:size
                         contentMode:PHImageContentModeAspectFill
                             options:options
                       resultHandler:^(UIImage *result, NSDictionary *info)
   {
     completion((result!= nil), result);
   }];
}

- (void)getImageForPHAsset:(PHAsset *)asset
                  withSize:(CGSize)size
                completion:(void (^)(BOOL ret, UIImage *image))completion
{
    if (![asset isKindOfClass:[PHAsset class]])
    {
        completion(NO, nil); return;
    }
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    [options setSynchronous:YES]; // called exactly once
    [self.manager requestImageForAsset:asset
                            targetSize:size
                           contentMode:PHImageContentModeAspectFill
                               options:options
                         resultHandler:^(UIImage *result, NSDictionary *info)
    {
      completion(YES, result);
      return;
      /*if (result)
      {
        completion(YES, result);
      }
      else
      {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        PHAsset *a = asset;
        CGFloat w = (a.pixelWidth > a.pixelHeight)?a.pixelHeight:a.pixelWidth;
        CGRect rect = CGRectMake(0, 0, 100, 100);
        options.normalizedCropRect = rect;
        options.synchronous = YES;
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize size  = CGSizeMake(180 * scale, 180 * scale);
        [self.manager requestImageForAsset:asset
                                targetSize:PHImageManagerMaximumSize
                               contentMode:PHImageContentModeAspectFill
                                   options:options
                             resultHandler:^(UIImage *result, NSDictionary *info)
         {
           completion((result!= nil), result);
         }];
      }*/
    }];
}

- (void)getOriginalImageForPHAsset:(PHAsset *)asset
                        completion:(void (^)(BOOL ret, UIImage *image))completion
{
  PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
  //
  options.resizeMode = PHImageRequestOptionsResizeModeFast;
  options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
  [options setSynchronous:NO];
  CGRect rect = CGRectMake(0, 0, asset.pixelWidth, asset.pixelHeight);
  options.normalizedCropRect = rect;
  [self.manager requestImageForAsset:asset
                          targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight)
                         contentMode:PHImageContentModeAspectFill
                             options:options
                       resultHandler:^(UIImage *result, NSDictionary *info)
   {
     completion((result!= nil), result);
   }];
}

- (void)getURLForPHAsset:(PHAsset *)asset
              completion:(void (^)(BOOL ret, NSURL *URL))completion
{
    if (![asset isKindOfClass:[PHAsset class]])
    {
        completion(NO, nil); return;
    }
    
    [asset requestContentEditingInputWithOptions:nil
                               completionHandler:^(PHContentEditingInput *contentEditingInput,
                                                   NSDictionary *info)
    {
        NSURL *imageURL = contentEditingInput.fullSizeImageURL;
         
        completion(YES, imageURL);
    }];
}

- (void)getAlbumsWithCompletion:(void (^)(BOOL ret, id obj))completion
{
  // 使用PHImageManager从PHAsset中请求图片
    NSMutableArray *tmpAry   = [[NSMutableArray alloc] init];
    PHFetchOptions *option   = [[PHFetchOptions alloc] init];
    option.predicate         = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeImage];
    option.sortDescriptors   = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate"
                                                               ascending:NO]];
    PHFetchResult  *cameraRo = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                        subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary
                                                                        options:nil];
    PHAssetCollection *colt  = [cameraRo lastObject];
    PHFetchResult *fetchR    = [PHAsset fetchAssetsInAssetCollection:colt
                                                             options:option];
    AlbumObj *obj   = [[AlbumObj alloc] init];
    obj.type        = PHAssetCollectionSubtypeSmartAlbumUserLibrary;
    obj.name        = colt.localizedTitle;
    obj.count = fetchR.count;
    obj.collection  = fetchR;
    if(obj.count)
    {
      [tmpAry addObject:obj];
      [self getPosterImageForAlbumObj:obj completion:^(BOOL ret, id objc) {
        obj.posterImage = objc;
      }];
      
    }
  
    // for iOS 9, we need to show ScreenShot Album
    /*
     if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0f)
     {
     PHFetchResult  *screenShot = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
     subtype:PHAssetCollectionSubtypeSmartAlbumScreenshots
     options:nil];
     PHAssetCollection *sColt   = [screenShot lastObject];
     PHFetchResult *sFetchR     = [PHAsset fetchAssetsInAssetCollection:sColt
     options:option];
     PGAlbumObj *sObj = [[PGAlbumObj alloc] init];
     sObj.type        = PHAssetCollectionSubtypeSmartAlbumScreenshots;
     sObj.name        = sColt.localizedTitle; sObj.count = sFetchR.count;
     sObj.collection  = sFetchR; if(sObj.count) [tmpAry addObject:sObj];
     }
     */
    PHAssetCollectionSubtype tp = PHAssetCollectionSubtypeAlbumRegular | PHAssetCollectionSubtypeAlbumSyncedAlbum;
    PHFetchResult *albums       = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                           subtype:tp
                                                                           options:nil];
    for (PHAssetCollection *col in albums)
    {
        @autoreleasepool
        {
            PHFetchResult *fRes = [PHAsset fetchAssetsInAssetCollection:col
                                                                options:option];
            AlbumObj *obj = [AlbumObj new]; obj.type = col.assetCollectionSubtype;
            obj.name = col.localizedTitle; obj.collection = fRes; obj.count = fRes.count;
            if (fRes.count > 0)
            {
              [tmpAry addObject:obj]; // drop empty album
              [self getPosterImageForAlbumObj:obj completion:^(BOOL ret, id objc) {
                obj.posterImage = objc;
              }];
            }
          
        }
    }
    
    completion(YES, tmpAry);
}

- (void)getPosterImageForAlbumObj:(AlbumObj *)album
                       completion:(void (^)(BOOL ret, id obj))completion
{
  PHAsset *asset = [album.collection lastObject];
   [self getThumbnailForAssetObj:asset withSize:CGSizeMake(180, 180)deliveryMode:PHImageRequestOptionsDeliveryModeOpportunistic   completion:^(BOOL ret, UIImage *image) {
     completion(ret, image);
   }];
}

- (void)getPhotosWithGroup:(AlbumObj *)obj
                completion:(void (^)(BOOL ret, id obj))completion
{
  if (![obj.collection isKindOfClass:[PHFetchResult class]])
  {
    completion(NO, nil); return;
  }
  NSMutableArray *elements = [[NSMutableArray alloc] initWithCapacity:0];
  PHFetchResult *fetchResult = (PHFetchResult *)obj.collection;
  for (NSInteger i = 0; i < fetchResult.count; i++)
  {
    PhotoObj *photoObj = [[PhotoObj alloc] init];
    photoObj.photoObj = [fetchResult objectAtIndex:i];
    [elements addObject:photoObj];
  }
  completion(YES, elements);
}

@end

