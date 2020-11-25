//
//  ELCImagePickerController.m
//  ELCImagePickerDemo
//
//  Created by ELC on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "ELCImagePickerController.h"
#import "ELCAsset.h"
#import "ELCAssetCell.h"
#import "ELCAssetTablePicker.h"
#import "ELCAlbumPickerController.h"
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "ELCConsole.h"
#import <Photos/Photos.h>

@implementation ELCImagePickerController

//Using auto synthesizers

- (id)initImagePicker
{
    ELCAlbumPickerController *albumPicker = [[ELCAlbumPickerController alloc] initWithStyle:UITableViewStylePlain];
    
    self = [super initWithRootViewController:albumPicker];
    if (self) {
        self.maximumImagesCount = 4;
        self.returnsImage = YES;
        self.returnsOriginalImage = YES;
        [albumPicker setParent:self];
        self.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.maximumImagesCount = 4;
        self.returnsImage = YES;
    }
    return self;
}

- (ELCAlbumPickerController *)albumPicker
{
    return self.viewControllers[0];
}

- (void)setMediaTypes:(NSArray *)mediaTypes
{
    self.albumPicker.mediaTypes = mediaTypes;
}

- (NSArray *)mediaTypes
{
    return self.albumPicker.mediaTypes;
}

- (void)cancelImagePicker
{
	if ([_imagePickerDelegate respondsToSelector:@selector(elcImagePickerControllerDidCancel:)]) {
		[_imagePickerDelegate performSelector:@selector(elcImagePickerControllerDidCancel:) withObject:self];
	}
}

- (BOOL)shouldSelectAsset:(ELCAsset *)asset previousCount:(NSUInteger)previousCount
{
  return YES;
}

- (BOOL)shouldDeselectAsset:(ELCAsset *)asset previousCount:(NSUInteger)previousCount;
{
    return YES;
}

-(void) initThredInABackgroundThread:(NSMutableDictionary*)args{
    [self performSelectorInBackground:@selector(initInOtherThread:) withObject:args];
}

-(void)initInOtherThread:(NSMutableDictionary*)args{
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    NSArray *_assets = [args objectForKey:@"assets"];
    
    for(ELCAsset *elcAsset in _assets) {
        
        PHAsset *asset = (PHAsset*) elcAsset.asset;
        
        [returnArray addObject:asset];
        
    }
    
    if([self.imagePickerDelegate respondsToSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:)]) {
        [self.imagePickerDelegate elcImagePickerController:self didFinishPickingMediaWithInfo:[NSArray arrayWithArray:returnArray]];
    }
}

- (void)selectedAssets:(NSArray *)assets
{
    NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
    [args setObject:assets forKey:@"assets"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self performSelector:@selector(initThredInABackgroundThread:) withObject:args afterDelay:0.2];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
}

- (BOOL)onOrder
{
    return [[ELCConsole mainConsole] onOrder];
}

- (void)setOnOrder:(BOOL)onOrder
{
    [[ELCConsole mainConsole] setOnOrder:onOrder];
}

@end
